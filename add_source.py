#!/usr/bin/env python3
"""
Probe a URL, detect which fetcher type fits, and append to feeds.yaml.

Usage:
  python add_source.py <url> [--name "Display Name"] [--id custom-slug]
                            [--keywords AI LLM ...] [--dry-run] [--yes]

Examples:
  python add_source.py https://www.youtube.com/@LennysPodcast
  python add_source.py https://stratechery.com/feed/ --name "Stratechery"
  python add_source.py https://podcasts.apple.com/us/podcast/lennys-podcast/id1627920305
  python add_source.py https://www.bloomberg.com --keywords AI LLM "Machine Learning"
"""

import argparse
import re
import sys
from pathlib import Path
from urllib.parse import urlparse, urljoin

import httpx
import yaml
from bs4 import BeautifulSoup
import feedparser

from fetchers import HEADERS, HTTP_TIMEOUT, _parse_sitemap_xml, _yt_dlp_opts

FEEDS_PATH = Path(__file__).parent / "feeds.yaml"
SUBSTACK_PROXY = "https://substack-proxy.rozenborg.workers.dev/?url="


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def normalize_url(url: str) -> str:
    return url if url.startswith(("http://", "https://")) else "https://" + url


def slugify(text: str) -> str:
    s = re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")
    return s or "source"


def _fetch(url: str) -> str | None:
    try:
        with httpx.Client(timeout=HTTP_TIMEOUT, headers=HEADERS, follow_redirects=True) as c:
            r = c.get(url)
            r.raise_for_status()
            return r.text
    except Exception:
        return None


def _looks_like_feed(content: str) -> bool:
    return bool(content and feedparser.parse(content).entries)


def _has_audio_enclosures(content: str) -> bool:
    feed = feedparser.parse(content)
    for entry in feed.entries[:5]:
        for enc in entry.get("enclosures", []):
            href = enc.get("href") or enc.get("url") or ""
            if "audio" in (enc.get("type") or "") or href.endswith((".mp3", ".m4a", ".wav")):
                return True
    return False


def _is_substack_host(url: str) -> bool:
    h = urlparse(url).hostname
    return bool(h and h.endswith("substack.com"))


def _wrap_substack(url: str) -> str:
    return f"{SUBSTACK_PROXY}{url}"


# ---------------------------------------------------------------------------
# Type detectors — each returns a partial source dict or None
# ---------------------------------------------------------------------------

def detect_youtube(url: str) -> dict | None:
    p = urlparse(url)
    if p.hostname not in ("www.youtube.com", "youtube.com", "m.youtube.com", "youtu.be"):
        return None
    if p.path.startswith("/watch") or p.hostname == "youtu.be":
        print("  This looks like a video URL, not a channel. Pass the channel page URL.", file=sys.stderr)
        return None
    out = {"type": "youtube", "channel_url": url}
    if m := re.match(r"/@([^/]+)", p.path):
        out["_suggested_name"] = m.group(1)
    return out


def detect_apple_podcasts(url: str) -> dict | None:
    p = urlparse(url)
    if p.hostname != "podcasts.apple.com":
        return None
    m = re.search(r"/id(\d+)", p.path)
    if not m:
        return None
    try:
        with httpx.Client(timeout=HTTP_TIMEOUT) as c:
            r = c.get(f"https://itunes.apple.com/lookup?id={m.group(1)}")
            r.raise_for_status()
            results = r.json().get("results") or []
    except Exception as e:
        print(f"  iTunes lookup failed: {e}", file=sys.stderr)
        return None
    if not results or not (feed_url := results[0].get("feedUrl")):
        return None
    out = {"type": "podcast", "feed_url": feed_url}
    if name := results[0].get("collectionName"):
        out["_suggested_name"] = name
    return out


def detect_direct_feed(url: str) -> dict | None:
    """The URL itself is a feed. Substack hosts always go via the proxy
    because *.substack.com feeds are Cloudflare-blocked from datacenter
    IPs (where this pipeline runs in CI), even if your local IP can reach
    them directly."""
    if _is_substack_host(url):
        proxied = _wrap_substack(url)
        content = _fetch(proxied)
        if content and _looks_like_feed(content):
            return {
                "type": "podcast" if _has_audio_enclosures(content) else "rss",
                "feed_url": proxied,
            }
        return None

    content = _fetch(url)
    if content and _looks_like_feed(content):
        return {
            "type": "podcast" if _has_audio_enclosures(content) else "rss",
            "feed_url": url,
        }
    return None


def detect_html_with_feed(url: str) -> dict | None:
    """HTML page advertising a feed via <link rel="alternate"> or common paths."""
    content = _fetch(url)
    if not content:
        return None
    soup = BeautifulSoup(content, "html.parser")
    candidates = []
    for link in soup.find_all("link", rel="alternate"):
        ltype = (link.get("type") or "").lower()
        href = link.get("href")
        if href and ("rss" in ltype or "atom" in ltype or "xml" in ltype):
            candidates.append(urljoin(url, href))
    p = urlparse(url)
    base = f"{p.scheme}://{p.hostname}"
    for path in ("/feed", "/rss", "/atom", "/feed.xml", "/rss.xml", "/index.xml", "/feed/"):
        candidates.append(urljoin(base, path))

    seen = set()
    suggested_name = None
    if soup.title and soup.title.string:
        suggested_name = soup.title.string.strip().split("|")[0].split(" - ")[0].strip() or None

    for c in candidates:
        if c in seen:
            continue
        seen.add(c)
        result = detect_direct_feed(c)
        if result:
            if suggested_name:
                result["_suggested_name"] = suggested_name
            return result
    return None


def detect(url: str) -> dict | None:
    for fn in (detect_youtube, detect_apple_podcasts, detect_direct_feed, detect_html_with_feed):
        if r := fn(url):
            return r
    return None


# ---------------------------------------------------------------------------
# Lightweight preview — validates the feed loads without spending API budget
# ---------------------------------------------------------------------------

def preview(source: dict) -> dict:
    """Returns {title, url, entry_count} for the latest entry. No API calls."""
    type_ = source["type"]

    if type_ in ("rss", "podcast"):
        feed = feedparser.parse(source["feed_url"])
        if feed.bozo and not feed.entries:
            raise RuntimeError(f"Feed parse error: {feed.bozo_exception}")
        if not feed.entries:
            raise RuntimeError("Feed has no entries")
        e = feed.entries[0]
        if type_ == "podcast":
            has_audio = any(
                "audio" in (enc.get("type") or "")
                or (enc.get("href") or enc.get("url") or "").endswith((".mp3", ".m4a", ".wav"))
                for enc in e.get("enclosures", [])
            )
            if not has_audio:
                raise RuntimeError("Latest entry has no audio enclosure — not a real podcast feed")
        return {
            "title": (e.get("title") or "Untitled").strip(),
            "url": e.get("link") or "",
            "entry_count": len(feed.entries),
        }

    if type_ == "youtube":
        import yt_dlp
        channel_url = source["channel_url"]
        if not channel_url.rstrip("/").endswith(("/videos", "/streams")):
            channel_url = channel_url.rstrip("/") + "/videos"
        opts = {**_yt_dlp_opts(), "extract_flat": "in_playlist", "playlistend": 3}
        with yt_dlp.YoutubeDL(opts) as ydl:
            info = ydl.extract_info(channel_url, download=False)
        entries = info.get("entries") or []
        if not entries:
            raise RuntimeError("No videos found at channel URL")
        e = entries[0]
        return {
            "title": (e.get("title") or "Untitled").strip(),
            "url": f"https://www.youtube.com/watch?v={e.get('id')}",
            "entry_count": len(entries),
        }

    if type_ == "sitemap":
        urls = _parse_sitemap_xml(source["url"], source.get("url_pattern"))
        if not urls:
            raise RuntimeError("Sitemap returned no URLs (or none matching url_pattern)")
        first = urls[0]["url"]
        return {
            "title": first.rstrip("/").split("/")[-1].replace("-", " ").title(),
            "url": first,
            "entry_count": len(urls),
        }

    raise RuntimeError(f"Unknown source type: {type_}")


# ---------------------------------------------------------------------------
# feeds.yaml writing — preserve existing structure & comments by appending text
# ---------------------------------------------------------------------------

def append_to_feeds(source: dict, path: Path = FEEDS_PATH):
    content = path.read_text()
    entry = yaml.dump([source], default_flow_style=False, sort_keys=False)
    indented = "\n".join(("  " + line) if line.strip() else line for line in entry.splitlines())
    settings_idx = content.find("\nsettings:")
    if settings_idx >= 0:
        new_content = content[:settings_idx].rstrip() + "\n\n" + indented + "\n" + content[settings_idx:]
    else:
        new_content = content.rstrip() + "\n\n" + indented + "\n"
    path.write_text(new_content)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Add a content source to feeds.yaml")
    parser.add_argument("url", help="URL to add (channel, blog, RSS feed, Apple podcast, etc.)")
    parser.add_argument("--name", help="Display name (auto-derived if omitted)")
    parser.add_argument("--id", help="Source slug (auto-derived from name)")
    parser.add_argument("--keywords", nargs="+", help="Keyword filter for general-interest sources")
    parser.add_argument("--yes", "-y", action="store_true", help="Skip confirmation prompt")
    parser.add_argument("--dry-run", action="store_true", help="Probe and preview but don't write")
    args = parser.parse_args()

    url = normalize_url(args.url)
    print(f"Probing {url} ...")
    detected = detect(url)
    if not detected:
        print("Could not detect source type. Add manually to feeds.yaml.", file=sys.stderr)
        sys.exit(1)

    suggested_name = detected.pop("_suggested_name", None)
    name = args.name or suggested_name or urlparse(url).hostname
    sid = args.id or slugify(name)

    source = {"id": sid, "name": name, **detected}
    if args.keywords:
        source["keywords"] = args.keywords

    print("\n--- Detected entry ---")
    print(yaml.dump([source], default_flow_style=False, sort_keys=False))

    print("Validating source (lightweight preview, no transcription/summarization) ...")
    try:
        sample = preview(source)
    except Exception as e:
        print(f"\nValidation failed: {e}", file=sys.stderr)
        sys.exit(1)

    print("\n--- Latest entry ---")
    print(f"Title: {sample['title']}")
    print(f"URL:   {sample['url']}")
    print(f"Total entries available: {sample['entry_count']}")
    print("--- end preview ---\n")
    print("(Run pull.py to see real summaries for this source.)\n")

    if args.dry_run:
        print("Dry-run mode — not writing to feeds.yaml.")
        return

    if not args.yes:
        try:
            ans = input("Append to feeds.yaml? [y/N] ")
        except (EOFError, KeyboardInterrupt):
            print("\nAborted.")
            sys.exit(1)
        if ans.strip().lower() not in ("y", "yes"):
            print("Aborted.")
            sys.exit(0)

    append_to_feeds(source)
    print(f"Added '{sid}' to feeds.yaml")


if __name__ == "__main__":
    main()
