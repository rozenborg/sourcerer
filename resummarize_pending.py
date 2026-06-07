"""
Re-summarize articles that landed in Supabase with summary=NULL, and
backfill card_teaser for articles that have a summary but no teaser yet.

Two passes per run:

1. summary backfill — pull.py inserts articles with summary=NULL when the
   Gemini API is briefly unavailable (most commonly transient 503s). This
   script picks those rows up and retries — first with the primary model
   (Gemini), then the fallback (Sonnet) if Gemini still fails.

2. teaser backfill — articles that have a summary but no card_teaser
   (either the inline presentation pass failed during pull.py, or the row
   predates the presentation pass entirely) get a teaser written via the
   configured presentation_model (Haiku 4.5). Capped per run so the
   first-time backfill of a large backlog drains over several days rather
   than blowing through cost in one go.

Re-fetches the original article content via trafilatura for pass 1, so it
works for rss/sitemap/scholarly_* sources where the article body is
web-extractable. podcast and youtube are skipped in pass 1 because
re-creating the transcript would require re-downloading audio/captions.
Pass 2 works for everything — it only needs the existing summary.

Run via .github/workflows/resummarize.yaml (09:00 UTC daily, one hour
after the main pull cron).
"""
import argparse
import os
import sys
from pathlib import Path
from typing import Any, cast

import yaml
from dotenv import load_dotenv

from fetchers import (
    extract_text, summarize, present,
    DEFAULT_MAX_TOKENS, DEFAULT_PRESENT_MODEL,
)

# Source types we can't easily re-summarize without re-doing transcription
SKIP_TYPES = {"podcast", "youtube"}

# Per-run cap on teaser backfill. Protects against a large backlog (e.g.
# the first run after the presentation pass ships) blowing through cost
# in one job. At ~$0.002/teaser and 250/run, that's ~$0.50 ceiling per
# cron run; backlog drains in a few days.
TEASER_BACKFILL_LIMIT = 250


def main():
    parser = argparse.ArgumentParser(
        description=(
            "Backfill articles that landed in Supabase with one or more "
            "derived fields missing. Two passes: NULL summaries, NULL "
            "card_teaser."
        )
    )
    parser.add_argument(
        "--since",
        metavar="YYYY-MM-DD",
        help=(
            "Only process articles with fetched_at >= this ISO date. Useful "
            "for testing prompt changes on recent rows without churning the "
            "whole backlog. Applies to both passes."
        ),
    )
    args = parser.parse_args()

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
    present_model  = settings.get("presentation_model", DEFAULT_PRESENT_MODEL)

    if args.since:
        print(f"Scoped mode: only processing articles with fetched_at >= {args.since}\n")

    # Supabase SDK types .data as list[dict[str, JSON]] where JSON is a
    # permissive union. We know the actual schema, so cast explicitly to
    # keep Pyright from flagging .get()/[] access on every field.
    pending_q = (
        sb.table("articles")
        .select("id, title, url, source_type, source_id")
        .is_("summary", "null")
        .order("fetched_at", desc=False)
    )
    if args.since:
        pending_q = pending_q.gte("fetched_at", args.since)
    pending = cast(list[dict[str, Any]], (pending_q.execute().data) or [])

    resolved = skipped = failed = 0

    if not pending:
        print("No pending articles to re-summarize.")
    else:
        print(f"Found {len(pending)} pending article(s) to re-summarize")
        print(f"Primary: {primary_model}  |  Fallback: {fallback_model}  |  max_tokens: {max_tokens}\n")

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

    print(f"\nDone (summary backfill). resolved={resolved}  skipped={skipped}  failed={failed}  total={len(pending)}")

    # --- Pass 2: card teaser backfill ---------------------------------
    print(f"\n=== Card teaser backfill (model: {present_model}, cap: {TEASER_BACKFILL_LIMIT}) ===\n")

    teaser_q = (
        sb.table("articles")
        .select("id, title, summary, source_type")
        .not_.is_("summary", "null")
        .is_("card_teaser", "null")
        .order("fetched_at", desc=False)
        .limit(TEASER_BACKFILL_LIMIT)
    )
    if args.since:
        teaser_q = teaser_q.gte("fetched_at", args.since)
    pending_teasers = cast(list[dict[str, Any]], (teaser_q.execute().data) or [])

    teaser_ok = teaser_fail = 0

    if not pending_teasers:
        print("No articles missing teasers.")
        return

    print(f"Found {len(pending_teasers)} article(s) missing teaser\n")

    for art in pending_teasers:
        title = (art.get("title") or "(untitled)")[:70]
        source_type = art.get("source_type") or "rss"
        summary = art.get("summary") or ""
        prefix = f"[{source_type}] {title}"

        teaser = present(
            summary,
            title=art.get("title") or "",
            source_type=source_type,
            model=present_model,
        )

        if not teaser:
            print(f"  FAIL  {prefix}")
            teaser_fail += 1
            continue

        sb.table("articles").update({
            "card_teaser":       teaser,
            "card_teaser_model": present_model,
        }).eq("id", art["id"]).execute()
        print(f"  ok    {prefix}  ({len(teaser)} chars)")
        teaser_ok += 1

    print(f"\nDone (teaser backfill). ok={teaser_ok}  failed={teaser_fail}  total={len(pending_teasers)}")


if __name__ == "__main__":
    main()
