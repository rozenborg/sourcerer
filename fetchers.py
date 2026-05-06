"""
Content fetching, extraction, transcription, and summarization.
Plain functions — no classes, no framework.
"""

import os
import re
import tempfile
import glob as globmod
from datetime import datetime, timezone, timedelta
from typing import Optional

import feedparser
import httpx
from bs4 import BeautifulSoup
import trafilatura

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.9",
    "Sec-Fetch-Dest": "document",
    "Sec-Fetch-Mode": "navigate",
    "Sec-Fetch-Site": "none",
    "Upgrade-Insecure-Requests": "1",
}

HTTP_TIMEOUT = 30
AUDIO_TIMEOUT = 600  # 10 min for large podcast downloads
MAX_CHUNK_SIZE_MB = 20
CHUNK_DURATION_MS = 10 * 60 * 1000  # 10 minutes


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _fetch_feed(feed_url: str):
    """Fetch RSS/Atom feed using browser headers, then parse with feedparser.
    Substack and some hosts block feedparser's default user-agent, returning
    HTML (Cloudflare challenge) instead of XML — causing parse errors in CI."""
    try:
        with httpx.Client(timeout=HTTP_TIMEOUT, headers=HEADERS, follow_redirects=True) as client:
            resp = client.get(feed_url)
            resp.raise_for_status()
        return feedparser.parse(resp.content)
    except Exception:
        # Fall back to feedparser's own HTTP fetch
        return feedparser.parse(feed_url)


def _parse_feed_date(entry) -> Optional[datetime]:
    """Extract datetime from a feedparser entry."""
    for attr in ("published_parsed", "updated_parsed"):
        parsed = getattr(entry, attr, None)
        if parsed:
            return datetime(*parsed[:6], tzinfo=timezone.utc)
    return None


def _extract_link(entry) -> Optional[str]:
    """Robustly extract the best URL from a feed entry."""
    if link := entry.get("link"):
        return link
    for l in entry.get("links", []):
        if l.get("rel") == "alternate":
            return l.get("href")
    if entry.get("links"):
        return entry["links"][0].get("href")
    id_val = entry.get("id", "")
    if id_val.startswith("http"):
        return id_val
    return None


def _matches_keywords(text: str, keywords: list[str]) -> bool:
    """Check if text matches any keyword (word-boundary regex)."""
    text_lower = text.lower()
    for kw in keywords:
        if re.search(r"\b" + re.escape(kw.lower()) + r"\b", text_lower):
            return True
    return False


def _extract_audio_url(entry) -> Optional[str]:
    """Extract audio URL from podcast feed entry enclosures or links."""
    for enc in entry.get("enclosures", []):
        url = enc.get("href") or enc.get("url")
        enc_type = enc.get("type", "")
        if url and ("audio" in enc_type or url.endswith((".mp3", ".m4a", ".wav"))):
            return url
    for link in entry.get("links", []):
        if "audio" in link.get("type", ""):
            return link.get("href")
    return None


# ---------------------------------------------------------------------------
# Text extraction
# ---------------------------------------------------------------------------

def extract_text(url: str, html: Optional[str] = None) -> Optional[str]:
    """Fetch URL (if html not provided) and extract main text via trafilatura."""
    try:
        if html is None:
            with httpx.Client(timeout=HTTP_TIMEOUT, headers=HEADERS, follow_redirects=True) as client:
                resp = client.get(url)
                resp.raise_for_status()
                html = resp.text
        return trafilatura.extract(html, url=url, include_comments=False) or None
    except Exception as e:
        print(f"    extract_text error for {url}: {e}")
        return None


def _rss_body_text(entry) -> Optional[str]:
    """Get full article text from RSS body if available (Substack includes it)."""
    for field in ("content", "summary_detail"):
        obj = entry.get(field)
        if isinstance(obj, list) and obj:
            obj = obj[0]
        if isinstance(obj, dict):
            value = obj.get("value", "")
            # Only use if it's substantial (not just a teaser)
            if len(value) > 500:
                text = BeautifulSoup(value, "html.parser").get_text(separator="\n", strip=True)
                if len(text) > 300:
                    return text
    return None


# ---------------------------------------------------------------------------
# Audio transcription
# ---------------------------------------------------------------------------

def transcribe_audio(audio_url: str) -> Optional[str]:
    """Download audio, chunk if needed, transcribe via Whisper API."""
    try:
        from openai import OpenAI
    except ImportError:
        print("    openai package not installed, skipping transcription")
        return None

    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        print("    OPENAI_API_KEY not set, skipping transcription")
        return None

    tmp_dir = None
    try:
        # Download
        print(f"    Downloading audio...")
        with httpx.Client(timeout=AUDIO_TIMEOUT, headers=HEADERS, follow_redirects=True) as client:
            resp = client.get(audio_url)
            resp.raise_for_status()

        ext = ".mp3"
        ct = resp.headers.get("content-type", "")
        if "mp4" in ct or audio_url.endswith(".m4a"):
            ext = ".m4a"

        tmp_dir = tempfile.mkdtemp(prefix="whisper_")
        tmp_path = os.path.join(tmp_dir, f"audio{ext}")
        with open(tmp_path, "wb") as f:
            f.write(resp.content)

        size_mb = os.path.getsize(tmp_path) / (1024 * 1024)
        print(f"    Downloaded {size_mb:.1f} MB")

        client = OpenAI(api_key=api_key)

        if size_mb > MAX_CHUNK_SIZE_MB:
            return _transcribe_chunked(tmp_path, tmp_dir, client)
        else:
            return _transcribe_file(tmp_path, client)

    except Exception as e:
        print(f"    Transcription error: {e}")
        return None
    finally:
        if tmp_dir and os.path.exists(tmp_dir):
            for f in globmod.glob(os.path.join(tmp_dir, "*")):
                try:
                    os.unlink(f)
                except OSError:
                    pass
            try:
                os.rmdir(tmp_dir)
            except OSError:
                pass


def _transcribe_file(path: str, client) -> Optional[str]:
    """Transcribe a single audio file."""
    try:
        with open(path, "rb") as f:
            return client.audio.transcriptions.create(model="whisper-1", file=f, response_format="text")
    except Exception as e:
        print(f"    Whisper API error: {e}")
        return None


def _transcribe_chunked(path: str, tmp_dir: str, client) -> Optional[str]:
    """Split audio into chunks and transcribe each."""
    try:
        from pydub import AudioSegment
    except ImportError:
        print("    pydub not installed, cannot chunk large audio")
        return None

    try:
        audio = AudioSegment.from_file(path)
        chunks = []
        start = 0
        i = 0
        while start < len(audio):
            end = min(start + CHUNK_DURATION_MS, len(audio))
            chunk_path = os.path.join(tmp_dir, f"chunk_{i:03d}.mp3")
            audio[start:end].export(chunk_path, format="mp3", bitrate="128k")
            chunks.append(chunk_path)
            start = end
            i += 1

        print(f"    Split into {len(chunks)} chunks, transcribing...")
        transcripts = []
        for j, chunk_path in enumerate(chunks):
            print(f"    Chunk {j+1}/{len(chunks)}...")
            text = _transcribe_file(chunk_path, client)
            if text:
                transcripts.append(text)

        full = " ".join(transcripts)
        print(f"    Transcribed {len(full)} characters")
        return full
    except Exception as e:
        print(f"    Chunked transcription error: {e}")
        return None


# ---------------------------------------------------------------------------
# Summarization
# ---------------------------------------------------------------------------

def summarize(text: str, source_type: str = "rss", title: str = "",
              model: str = "claude-sonnet-4-20250514") -> Optional[str]:
    """Summarize text via Claude API. Returns a punchy headline + detailed bullets."""
    try:
        from anthropic import Anthropic
    except ImportError:
        print("    anthropic package not installed, skipping summarization")
        return None

    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        print("    ANTHROPIC_API_KEY not set, skipping summarization")
        return None

    # Truncate to ~30k chars to stay within context limits
    content = text[:30000]

    type_hint = ""
    if source_type == "podcast":
        type_hint = "This is a podcast transcript. Focus on the main arguments and insights from each speaker. Ignore filler, ads, and tangential small talk.\n\n"
    elif source_type == "sitemap":
        type_hint = "This is a company blog post. Focus on product announcements, technical capabilities, and strategic implications.\n\n"

    # Keep prompt in sync with workers/summarize-api/worker.js
    prompt = (
        "You are an expert analyst creating an intelligence briefing.\n\n"
        "Produce a two-part summary:\n\n"
        "1. HEADLINE: One or two punchy sentences — the \"so what?\" of this piece. "
        "Make it concrete and specific, not generic. No bullet points, no bold, just a plain paragraph.\n\n"
        "2. Then a line containing only --- (a horizontal rule).\n\n"
        "3. DETAILS: 5-8 bullet points covering key facts, strategic implications, and actionable insights. "
        "Use markdown bullet points (- **Bold label** explanation). Be specific and concise.\n\n"
        "No introductory phrases, no section headings — just the headline paragraph, then ---, then the bullets.\n\n"
        f"{type_hint}"
        f"Title: {title}\n\n"
        f"Content:\n{content}"
    )

    try:
        client = Anthropic(api_key=api_key)
        resp = client.messages.create(
            model=model,
            max_tokens=1024,
            messages=[{"role": "user", "content": prompt}],
        )
        return resp.content[0].text
    except Exception as e:
        print(f"    Summarization error: {e}")
        return None


# ---------------------------------------------------------------------------
# Source fetchers
# ---------------------------------------------------------------------------

def fetch_rss(source: dict, seen_urls: set, settings: dict) -> list[dict]:
    """
    Fetch articles from an RSS/Substack feed.
    Returns list of dicts: {title, url, date, source_id, source_type, summary}
    """
    feed_url = source.get("feed_url")
    if not feed_url:
        raise ValueError(f"No feed_url for source {source['id']}")

    feed = _fetch_feed(feed_url)
    if feed.bozo and not feed.entries:
        raise ValueError(f"Feed parse error: {feed.bozo_exception}")

    lookback = datetime.now(timezone.utc) - timedelta(days=settings.get("lookback_days", 3))
    max_posts = settings.get("max_posts_per_source", 5)
    keywords = source.get("keywords")
    model = settings.get("summarization_model", "claude-sonnet-4-20250514")

    # Parse and sort by date (newest first)
    entries = []
    for entry in feed.entries:
        dt = _parse_feed_date(entry)
        entries.append((dt, entry))
    entries.sort(key=lambda x: x[0] or datetime.min.replace(tzinfo=timezone.utc), reverse=True)

    articles = []
    for dt, entry in entries:
        if len(articles) >= max_posts:
            break
        if dt and dt < lookback:
            continue

        url = _extract_link(entry)
        if not url or url in seen_urls:
            continue

        title = entry.get("title", "Untitled").strip()

        # Keyword filter
        if keywords:
            check_text = title + " " + entry.get("summary", "") + " " + entry.get("description", "")
            if not _matches_keywords(check_text, keywords):
                continue

        print(f"  [{source['id']}] {title[:60]}")

        # Try RSS body first (Substack includes full text), then fetch URL
        text = _rss_body_text(entry) or extract_text(url)

        if not text or len(text) < 100:
            print(f"    Skipping — no substantial text extracted")
            continue

        summary = summarize(text, source_type="rss", title=title, model=model)

        articles.append({
            "title": title,
            "url": url,
            "date": dt,
            "source_id": source["id"],
            "source_name": source["name"],
            "source_type": "rss",
            "summary": summary,
        })

    return articles


def fetch_sitemap(source: dict, seen_urls: set, settings: dict) -> list[dict]:
    """Fetch articles from a sitemap (recursive for sitemap indices)."""
    sitemap_url = source.get("url")
    if not sitemap_url:
        raise ValueError(f"No url for sitemap source {source['id']}")

    max_posts = settings.get("max_posts_per_source", 5)
    keywords = source.get("keywords")
    url_pattern = source.get("url_pattern")
    model = settings.get("summarization_model", "claude-sonnet-4-20250514")
    lookback = datetime.now(timezone.utc) - timedelta(days=settings.get("lookback_days", 3))

    # Recursively parse sitemap
    urls = _parse_sitemap_xml(sitemap_url, url_pattern)

    # Sort by date (newest first)
    urls.sort(key=lambda x: x["date"] or datetime.min.replace(tzinfo=timezone.utc), reverse=True)

    # --- Pre-filter before expensive HTTP fetches ---
    candidates = []
    for item in urls:
        page_url = item["url"]

        # Skip already seen
        if page_url in seen_urls:
            continue

        # Skip old content (respect lookback_days)
        if item["date"] and item["date"] < lookback:
            continue

        # Cheap keyword pre-filter: check URL slug before fetching the page
        if keywords:
            slug_text = page_url.rstrip("/").split("/")[-1].replace("-", " ")
            if not _matches_keywords(slug_text, keywords):
                continue

        candidates.append(item)

    # Limit how many pages we actually fetch (avoid hammering servers)
    candidates = candidates[:max_posts * 2]

    articles = []
    for item in candidates:
        if len(articles) >= max_posts:
            break

        page_url = item["url"]

        # Fetch and extract text
        text = extract_text(page_url)
        if not text or len(text) < 100:
            continue

        # Derive title from URL slug
        title = page_url.rstrip("/").split("/")[-1].replace("-", " ").title()

        print(f"  [{source['id']}] {title[:60]}")
        summary = summarize(text, source_type="sitemap", title=title, model=model)

        articles.append({
            "title": title,
            "url": page_url,
            "date": item["date"],
            "source_id": source["id"],
            "source_name": source["name"],
            "source_type": "sitemap",
            "summary": summary,
        })

    return articles


def _parse_sitemap_xml(url: str, pattern: Optional[str] = None) -> list[dict]:
    """Recursively parse sitemap XML, returning list of {url, date} dicts."""
    try:
        with httpx.Client(timeout=HTTP_TIMEOUT, headers=HEADERS, follow_redirects=True) as client:
            resp = client.get(url)
            resp.raise_for_status()

        soup = BeautifulSoup(resp.content, "xml")

        # Sitemap index — recurse
        sitemaps = soup.find_all("sitemap")
        if sitemaps:
            results = []
            for sm in sitemaps:
                loc = sm.find("loc")
                if loc:
                    results.extend(_parse_sitemap_xml(loc.get_text(strip=True), pattern))
            return results

        # Regular sitemap — collect URLs
        results = []
        for url_tag in soup.find_all("url"):
            loc = url_tag.find("loc")
            if not loc:
                continue
            page_url = loc.get_text(strip=True)

            if pattern and pattern not in page_url:
                continue

            dt = None
            lastmod = url_tag.find("lastmod")
            if lastmod:
                try:
                    dt = datetime.fromisoformat(lastmod.get_text(strip=True).replace("Z", "+00:00"))
                except (ValueError, TypeError):
                    pass

            results.append({"url": page_url, "date": dt})

        return results

    except Exception as e:
        print(f"    Sitemap parse error for {url}: {e}")
        return []


def fetch_podcast(source: dict, seen_urls: set, settings: dict) -> list[dict]:
    """Fetch and transcribe podcast episodes."""
    feed_url = source.get("feed_url")
    if not feed_url:
        raise ValueError(f"No feed_url for podcast source {source['id']}")

    feed = _fetch_feed(feed_url)
    if feed.bozo and not feed.entries:
        raise ValueError(f"Feed parse error: {feed.bozo_exception}")

    lookback = datetime.now(timezone.utc) - timedelta(days=settings.get("lookback_days", 3))
    max_posts = settings.get("max_posts_per_source", 5)
    model = settings.get("summarization_model", "claude-sonnet-4-20250514")

    # Sort by date
    entries = []
    for entry in feed.entries:
        dt = _parse_feed_date(entry)
        entries.append((dt, entry))
    entries.sort(key=lambda x: x[0] or datetime.min.replace(tzinfo=timezone.utc), reverse=True)

    articles = []
    for dt, entry in entries:
        if len(articles) >= max_posts:
            break
        if dt and dt < lookback:
            continue

        url = _extract_link(entry)
        if not url or url in seen_urls:
            continue

        audio_url = _extract_audio_url(entry)
        if not audio_url:
            print(f"  [{source['id']}] No audio URL for: {entry.get('title', 'Untitled')}")
            continue

        title = entry.get("title", "Untitled").strip()
        print(f"  [{source['id']}] {title[:60]}")

        transcript = transcribe_audio(audio_url)
        if not transcript or len(transcript) < 100:
            # Fall back to episode description
            transcript = entry.get("summary", "") or entry.get("description", "")
            if not transcript or len(transcript) < 100:
                print(f"    Skipping — no transcript or description")
                continue
            print(f"    Using episode description (no transcript)")

        summary = summarize(transcript, source_type="podcast", title=title, model=model)

        articles.append({
            "title": title,
            "url": url,
            "date": dt,
            "source_id": source["id"],
            "source_name": source["name"],
            "source_type": "podcast",
            "summary": summary,
        })

    return articles
