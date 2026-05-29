"""
Re-summarize articles that landed in Supabase with summary=NULL.

The daily pull.py inserts articles with summary=NULL when the Gemini API
is briefly unavailable (most commonly transient 503s). This script picks
those rows up and retries — first with the primary model (Gemini), then
the fallback (Sonnet) if Gemini still fails.

Re-fetches the original article content via trafilatura, so it works for
rss/sitemap/scholarly_* sources where the article body is web-extractable.
podcast and youtube are skipped here because re-creating the transcript
would require re-downloading audio/captions — that path is more expensive
than just letting tomorrow's daily cron try again on the next item.

Run via .github/workflows/resummarize.yaml (09:00 UTC daily, one hour
after the main pull cron).
"""
import os
import sys
from pathlib import Path
from typing import Any, cast

import yaml
from dotenv import load_dotenv

from fetchers import extract_text, summarize, DEFAULT_MAX_TOKENS

# Source types we can't easily re-summarize without re-doing transcription
SKIP_TYPES = {"podcast", "youtube"}


def main():
    load_dotenv()

    sb_url = os.environ.get("SUPABASE_URL")
    sb_key = os.environ.get("SUPABASE_SERVICE_KEY")
    if not sb_url or not sb_key:
        print("SUPABASE_URL / SUPABASE_SERVICE_KEY not set", file=sys.stderr)
        sys.exit(1)

    try:
        from supabase import create_client
    except ImportError:
        print("supabase package not installed", file=sys.stderr)
        sys.exit(1)

    sb = create_client(sb_url, sb_key)

    feeds_path = Path(__file__).with_name("feeds.yaml")
    cfg = yaml.safe_load(feeds_path.read_text())
    settings = cfg.get("settings", {})
    primary_model  = settings.get("summarization_model", "gemini-2.5-flash")
    fallback_model = settings.get("summarization_fallback_model", "claude-sonnet-4-6")
    max_tokens     = settings.get("summarization_max_tokens", DEFAULT_MAX_TOKENS)

    # Supabase SDK types .data as list[dict[str, JSON]] where JSON is a
    # permissive union. We know the actual schema, so cast explicitly to
    # keep Pyright from flagging .get()/[] access on every field.
    pending = cast(list[dict[str, Any]], (
        sb.table("articles")
        .select("id, title, url, source_type, source_id")
        .is_("summary", "null")
        .order("fetched_at", desc=False)
        .execute()
        .data
    ) or [])

    if not pending:
        print("No pending articles. Nothing to do.")
        return

    print(f"Found {len(pending)} pending article(s) to re-summarize")
    print(f"Primary: {primary_model}  |  Fallback: {fallback_model}  |  max_tokens: {max_tokens}\n")

    resolved = skipped = failed = 0

    for article in pending:
        title = (article.get("title") or "(untitled)")[:70]
        source_type = article.get("source_type") or "unknown"
        url = article.get("url") or ""

        prefix = f"[{source_type}] {title}"

        if source_type in SKIP_TYPES:
            print(f"  skip  {prefix}  (transcript-based source, not re-fetchable)")
            skipped += 1
            continue

        if not url:
            print(f"  skip  {prefix}  (no URL)")
            skipped += 1
            continue

        text = extract_text(url)
        if not text:
            print(f"  skip  {prefix}  (extract_text returned nothing)")
            skipped += 1
            continue

        # Try primary first; fall back if it returns None.
        summary = summarize(
            text, source_type=source_type, title=article.get("title") or "",
            model=primary_model, max_tokens=max_tokens,
        )
        used = primary_model

        if not summary:
            print(f"  retry {prefix}  (primary failed, trying {fallback_model})")
            summary = summarize(
                text, source_type=source_type, title=article.get("title") or "",
                model=fallback_model, max_tokens=max_tokens,
            )
            used = fallback_model

        if not summary:
            print(f"  FAIL  {prefix}  (both models failed)")
            failed += 1
            continue

        sb.table("articles").update({"summary": summary}).eq("id", article["id"]).execute()
        print(f"  ok    {prefix}  ({used}, {len(summary)} chars)")
        resolved += 1

    print(f"\nDone. resolved={resolved}  skipped={skipped}  failed={failed}  total={len(pending)}")


if __name__ == "__main__":
    main()
