"""
Content fetching, extraction, transcription, and summarization.
Plain functions — no classes, no framework.
"""

import os
import re
import json
import time
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


def _yt_dlp_opts() -> dict:
    """Common yt-dlp options. Adds cookiefile when YOUTUBE_COOKIES_FILE
    is set — required from datacenter IPs (GitHub Actions) where YouTube's
    player API rejects unauthenticated requests."""
    cookiefile = os.environ.get("YOUTUBE_COOKIES_FILE")
    opts = {"quiet": True, "skip_download": True, "no_warnings": True}
    if cookiefile and os.path.exists(cookiefile) and os.path.getsize(cookiefile) > 0:
        opts["cookiefile"] = cookiefile
    else:
        # Without cookies (local dev), the android client exposes captions
        # where the default web client returns empty dicts.
        opts["extractor_args"] = {"youtube": {"player_client": ["android"]}}
    return opts


def _fetch_youtube_transcript(video_id: str) -> Optional[str]:
    """Fetch captions for a YouTube video.

    Uses yt-dlp's `android` player_client to discover the caption track URL,
    then fetches the json3 file directly. Other approaches we tried:
    - youtube-transcript-api: IP-blocked from datacenter ranges (incl. GitHub Actions)
    - yt-dlp `web` client: returns empty subtitle dicts in CI
    The android client consistently exposes captions where the others don't."""
    try:
        import yt_dlp
    except ImportError:
        print("    yt-dlp not installed, skipping captions")
        return None

    try:
        with yt_dlp.YoutubeDL(_yt_dlp_opts()) as ydl:
            # process=False skips format selection (which can fail in CI even
            # with download=False); subtitle URLs are still populated.
            info = ydl.extract_info(
                f"https://www.youtube.com/watch?v={video_id}",
                download=False, process=False,
            )
    except Exception as e:
        print(f"    Caption metadata error: {e}")
        return None

    # Prefer manual subs over auto; prefer json3 over other formats
    subs = info.get("subtitles") or {}
    auto = info.get("automatic_captions") or {}
    tracks = subs.get("en") or auto.get("en") or subs.get("en-US") or auto.get("en-US") or []
    if not tracks:
        return None
    target = next((t for t in tracks if t.get("ext") == "json3"), tracks[0])
    track_url = target.get("url")
    if not track_url:
        return None

    try:
        with httpx.Client(timeout=HTTP_TIMEOUT, headers=HEADERS, follow_redirects=True) as c:
            r = c.get(track_url)
            r.raise_for_status()
            data = r.json()
    except Exception as e:
        print(f"    Caption fetch error: {e}")
        return None

    text = " ".join(
        seg["utf8"]
        for ev in data.get("events", [])
        for seg in (ev.get("segs") or [])
        if seg.get("utf8")
    )
    text = " ".join(text.split())
    return text or None


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
    elif source_type == "youtube":
        type_hint = "This is a YouTube video transcript from auto-generated or manual captions. Focus on the speakers' main arguments and insights. Captions can have transcription errors and miss visual context — work from the textual content you have.\n\n"
    elif source_type == "scholarly":
        type_hint = "This is a scholarly paper abstract. Lead with the empirical finding and what it implies for practice — not the methodology. Focus on what the paper reveals about how AI changes work, decisions, controls, or outcomes for organizations and professionals.\n\n"

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


def fetch_youtube(source: dict, seen_urls: set, settings: dict) -> list[dict]:
    """
    Fetch videos from a YouTube channel.
    Lists videos via yt-dlp (YouTube's videos.xml feed is blocked from
    most datacenter IPs), then pulls captions via youtube-transcript-api.
    Videos without captions are skipped.

    Note: lookback_days isn't applied here — flat extraction doesn't give
    per-video timestamps cheaply, and max_posts + seen_urls dedup is
    enough in practice (listings come back newest-first).
    """
    channel_url = source.get("channel_url") or source.get("feed_url")
    if not channel_url:
        raise ValueError(f"No channel_url for youtube source {source['id']}")

    # Normalize: accept old videos.xml URLs and bare channel URLs alike
    if "/feeds/videos.xml" in channel_url:
        m = re.search(r"channel_id=(UC[\w-]+)", channel_url)
        if m:
            channel_url = f"https://www.youtube.com/channel/{m.group(1)}"
    if not channel_url.rstrip("/").endswith(("/videos", "/streams")):
        channel_url = channel_url.rstrip("/") + "/videos"

    try:
        import yt_dlp
    except ImportError:
        raise RuntimeError("yt-dlp not installed (pip install yt-dlp)")

    max_posts = settings.get("max_posts_per_source", 5)
    model = settings.get("summarization_model", "claude-sonnet-4-20250514")

    ydl_opts = {**_yt_dlp_opts(), "extract_flat": "in_playlist", "playlistend": max_posts * 3}

    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(channel_url, download=False)
    except Exception as e:
        raise RuntimeError(f"yt-dlp listing failed: {e}")

    entries = info.get("entries") or []

    articles = []
    for entry in entries:
        if len(articles) >= max_posts:
            break

        video_id = entry.get("id")
        if not video_id:
            continue

        url = f"https://www.youtube.com/watch?v={video_id}"
        if url in seen_urls:
            continue

        title = (entry.get("title") or "Untitled").strip()
        print(f"  [{source['id']}] {title[:60]}")

        transcript = _fetch_youtube_transcript(video_id)
        if not transcript or len(transcript) < 100:
            print(f"    Skipping — no captions available")
            continue

        summary = summarize(transcript, source_type="youtube", title=title, model=model)

        articles.append({
            "title": title,
            "url": url,
            "date": None,
            "source_id": source["id"],
            "source_name": source["name"],
            "source_type": "youtube",
            "summary": summary,
        })

    return articles


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


# ---------------------------------------------------------------------------
# Scholarly papers — Semantic Scholar recommender + Claude-scored Mollick filter
# ---------------------------------------------------------------------------

S2_BASE = "https://api.semanticscholar.org"
S2_FIELDS = "title,abstract,year,publicationDate,authors,url,externalIds"


def _s2_headers() -> dict:
    api_key = os.environ.get("SEMANTIC_SCHOLAR_API_KEY")
    return {"x-api-key": api_key} if api_key else {}


def _s2_get(path: str, params: dict | None = None, retries: int = 3) -> Optional[dict]:
    """GET against S2 with backoff on 429s. Returns JSON dict on 200, else None."""
    delay = 1.0
    for attempt in range(retries):
        try:
            with httpx.Client(timeout=HTTP_TIMEOUT, headers=_s2_headers()) as c:
                r = c.get(f"{S2_BASE}{path}", params=params)
            if r.status_code == 200:
                return r.json()
            if r.status_code == 429 and attempt < retries - 1:
                time.sleep(delay)
                delay *= 2
                continue
            return None
        except Exception:
            if attempt < retries - 1:
                time.sleep(delay)
                delay *= 2
                continue
            return None
    return None


def _resolve_seed(ref: str) -> Optional[str]:
    """Resolve any seed reference (DOI, arXiv ID, URL, or title) to an S2 paperId."""
    # Normalize URL forms to canonical IDs
    if m := re.match(r"https?://arxiv\.org/abs/([\w.\-]+)", ref):
        ref = f"ARXIV:{m.group(1)}"
    elif m := re.match(r"https?://(?:dx\.)?doi\.org/(.+)", ref):
        ref = f"DOI:{m.group(1)}"
    elif re.match(r"^10\.\d+/", ref):
        ref = f"DOI:{ref}"

    # Canonical ID — direct lookup
    if re.match(r"^(DOI|ARXIV|S2|PMID|MAG|ACL|CorpusId):", ref, re.IGNORECASE):
        data = _s2_get(f"/graph/v1/paper/{ref}", {"fields": "paperId"})
        if data:
            return data.get("paperId")
        print(f"    [{ref}] direct lookup failed")
        return None

    # Title — use fuzzy /paper/search (more forgiving than /search/match)
    data = _s2_get("/graph/v1/paper/search", {"query": ref[:300], "limit": 3, "fields": "paperId,title"})
    if data and (results := data.get("data") or []):
        return results[0].get("paperId")
    print(f"    title search '{ref[:60]}...' returned no results")
    return None


def _s2_recommendations(seed_paper_ids: list, limit: int = 100) -> list:
    """POST to the multi-seed recommender. Returns list of candidate paper dicts."""
    try:
        with httpx.Client(timeout=HTTP_TIMEOUT, headers=_s2_headers()) as c:
            r = c.post(
                f"{S2_BASE}/recommendations/v1/papers",
                json={"positivePaperIds": seed_paper_ids},
                params={"fields": S2_FIELDS, "limit": limit},
            )
            r.raise_for_status()
            return r.json().get("recommendedPapers") or []
    except Exception as e:
        print(f"    Recommendation API error: {e}")
        return []


MOLLICK_RUBRIC_PROMPT = """\
Score this academic paper against the Mollick-style high-signal research filter. The filter prefers papers that change what a smart organization should do next.

Score 0-20 across these dimensions:
- Realistic work task (0-3): Does it study real or realistic professional work?
- Human/AI comparison (0-3): Compares human, AI, and/or human+AI with meaningful baselines?
- Evidence design (0-3): RCT, field experiment, preregistered study, strong causal/quasi-causal design?
- Boundary/failure insight (0-3): Identifies where AI helps vs. hurts, overreliance, hallucination, calibration failure?
- Heterogeneity (0-2): Differences by skill, role, expertise, task type, team structure?
- Managerial implication (0-3): Could the result change workflow, training, controls, or organizational design?
- Memorable operating principle (0-2): Compressible into an executive concept?
- Timeliness (0-1): Models/tools or concepts still relevant?

Respond with ONLY valid JSON, no preamble:
{{"score": <integer 0-20>, "reason": "<one-sentence rationale>"}}

Title: {title}

Abstract:
{abstract}
"""


def _score_mollick_likeness(title: str, abstract: str, model: str) -> tuple[int, str]:
    """Single Claude call. Returns (score, reason). Score 0 means scoring failed."""
    if not abstract:
        return 0, "no abstract"
    try:
        from anthropic import Anthropic
    except ImportError:
        return 0, "anthropic package not installed"

    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        return 0, "ANTHROPIC_API_KEY not set"

    prompt = MOLLICK_RUBRIC_PROMPT.format(title=title[:300], abstract=abstract[:5000])

    try:
        client = Anthropic(api_key=api_key)
        resp = client.messages.create(
            model=model,
            max_tokens=200,
            messages=[{"role": "user", "content": prompt}],
        )
        text = resp.content[0].text.strip()
    except Exception as e:
        return 0, f"scoring API error: {e}"

    # Strip markdown fences if present
    text = re.sub(r"^```(?:json)?\s*", "", text)
    text = re.sub(r"\s*```$", "", text)
    try:
        data = json.loads(text)
        return int(data.get("score", 0)), str(data.get("reason", "no reason"))
    except (json.JSONDecodeError, ValueError, TypeError):
        # Regex fallback for non-strict-JSON responses
        score_m = re.search(r'"score"\s*:\s*(\d+)', text)
        reason_m = re.search(r'"reason"\s*:\s*"([^"]*)"', text)
        if score_m:
            return int(score_m.group(1)), (reason_m.group(1) if reason_m else "")
    return 0, "could not parse score"


def _candidate_url(candidate: dict) -> Optional[str]:
    """Prefer canonical external URLs (DOI, arXiv) over the S2 paper page."""
    ext = candidate.get("externalIds") or {}
    if doi := ext.get("DOI"):
        return f"https://doi.org/{doi}"
    if arxiv_id := ext.get("ArXiv"):
        return f"https://arxiv.org/abs/{arxiv_id}"
    return candidate.get("url")


def _candidate_date(candidate: dict) -> Optional[datetime]:
    if pub := candidate.get("publicationDate"):
        try:
            return datetime.fromisoformat(pub).replace(tzinfo=timezone.utc)
        except ValueError:
            pass
    if year := candidate.get("year"):
        try:
            return datetime(int(year), 1, 1, tzinfo=timezone.utc)
        except (ValueError, TypeError):
            pass
    return None


def fetch_scholarly_rss(source: dict, seen_urls: set, settings: dict) -> list[dict]:
    """
    Academic-paper RSS feeds (SSRN eJournals, NBER recent-papers, etc.) with
    Mollick-likeness scoring applied per entry before summarization.
    Use feed_urls (list) or feed_url (single) in the source config.
    """
    feed_urls = source.get("feed_urls")
    if not feed_urls and (single := source.get("feed_url")):
        feed_urls = [single]
    if not feed_urls:
        raise ValueError(f"No feed_urls/feed_url for {source['id']}")

    score_threshold = source.get("score_threshold", 12)
    lookback_days = source.get("lookback_days", 30)
    max_posts = source.get("max_posts", settings.get("max_posts_per_source", 10))
    scoring_model = source.get("scoring_model") or settings.get("scoring_model", "claude-haiku-4-5-20251001")
    summarization_model = settings.get("summarization_model", "claude-sonnet-4-20250514")

    cutoff = datetime.now(timezone.utc) - timedelta(days=lookback_days)

    # Collect dated entries across feeds, deduped by link
    pool = []
    seen_in_pool = set()
    for feed_url in feed_urls:
        feed = _fetch_feed(feed_url)
        if feed.bozo and not feed.entries:
            print(f"    Feed parse error for {feed_url}: {feed.bozo_exception}")
            continue
        for entry in feed.entries:
            link = _extract_link(entry)
            if not link or link in seen_in_pool:
                continue
            seen_in_pool.add(link)
            dt = _parse_feed_date(entry)
            if dt and dt < cutoff:
                continue
            pool.append((dt, entry, link))

    pool.sort(key=lambda x: x[0] or datetime.min.replace(tzinfo=timezone.utc), reverse=True)

    articles = []
    for dt, entry, url in pool:
        if len(articles) >= max_posts:
            break
        if url in seen_urls:
            continue

        title = (entry.get("title") or "Untitled").strip()
        # Pull abstract from RSS body, then summary, then description
        raw_html = ""
        for field in ("content", "summary_detail"):
            obj = entry.get(field)
            if isinstance(obj, list) and obj:
                obj = obj[0]
            if isinstance(obj, dict) and obj.get("value"):
                raw_html = obj["value"]
                break
        if not raw_html:
            raw_html = entry.get("summary") or entry.get("description") or ""
        abstract = BeautifulSoup(raw_html, "html.parser").get_text(separator=" ", strip=True) if raw_html else ""
        abstract = " ".join(abstract.split())

        if len(abstract) < 200:
            continue  # likely a stub or thin entry — skip rather than score

        score, reason = _score_mollick_likeness(title, abstract, scoring_model)
        marker = "✓" if score >= score_threshold else "·"
        print(f"  [{source['id']}] {marker} {score:>2}/20  {title[:55]}")

        if score < score_threshold:
            continue

        summary = summarize(abstract, source_type="scholarly", title=title, model=summarization_model)
        if summary:
            summary = f"_Mollick-likeness: {score}/20 — {reason}_\n\n{summary}"

        articles.append({
            "title": title,
            "url": url,
            "date": dt,
            "source_id": source["id"],
            "source_name": source["name"],
            "source_type": "scholarly",  # store as scholarly so DB queries treat them uniformly
            "summary": summary,
        })

    return articles


def fetch_scholarly(source: dict, seen_urls: set, settings: dict) -> list[dict]:
    """
    Fetch scholarly papers via Semantic Scholar's recommendation API,
    seeded with curated 'taste' papers, filtered by a Claude-scored
    Mollick-likeness rubric.
    """
    seed_refs = source.get("seed_papers") or []
    if not seed_refs:
        raise ValueError(f"No seed_papers for scholarly source {source['id']}")

    score_threshold  = source.get("score_threshold", 14)
    max_candidates   = source.get("max_candidates", 100)
    lookback_days    = source.get("lookback_days", 90)
    scoring_model    = source.get("scoring_model") or settings.get("scoring_model", "claude-haiku-4-5-20251001")
    summarization_model = settings.get("summarization_model", "claude-sonnet-4-20250514")
    max_posts        = source.get("max_posts", settings.get("max_posts_per_source", 10))

    print(f"  Resolving {len(seed_refs)} seed papers ...")
    seed_ids = []
    for ref in seed_refs:
        if pid := _resolve_seed(ref):
            seed_ids.append(pid)
    print(f"  Resolved {len(seed_ids)}/{len(seed_refs)} seeds")
    if not seed_ids:
        raise RuntimeError("No seeds resolved to Semantic Scholar IDs")

    print(f"  Requesting up to {max_candidates} recommendations ...")
    candidates = _s2_recommendations(seed_ids, limit=max_candidates)
    print(f"  Got {len(candidates)} candidates")

    cutoff = datetime.now(timezone.utc) - timedelta(days=lookback_days)
    articles = []

    for candidate in candidates:
        if len(articles) >= max_posts:
            break

        url = _candidate_url(candidate)
        if not url or url in seen_urls:
            continue

        pub_date = _candidate_date(candidate)
        if pub_date and pub_date < cutoff:
            continue

        abstract = candidate.get("abstract") or ""
        if len(abstract) < 100:
            continue

        title = (candidate.get("title") or "Untitled").strip()
        score, reason = _score_mollick_likeness(title, abstract, scoring_model)
        marker = "✓" if score >= score_threshold else "·"
        print(f"  [{source['id']}] {marker} {score:>2}/20  {title[:55]}")

        if score < score_threshold:
            continue

        summary = summarize(abstract, source_type="scholarly", title=title, model=summarization_model)
        if summary:
            summary = f"_Mollick-likeness: {score}/20 — {reason}_\n\n{summary}"

        articles.append({
            "title": title,
            "url": url,
            "date": pub_date,
            "source_id": source["id"],
            "source_name": source["name"],
            "source_type": "scholarly",
            "summary": summary,
        })

    return articles
