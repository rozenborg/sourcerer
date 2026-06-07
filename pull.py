#!/usr/bin/env python3
"""
Sourcerer: headless content database.
Fetches content from configured sources, summarizes via Claude, upserts into Supabase.
Run via GitHub Actions or locally: python pull.py
"""

import os
import sys
from datetime import datetime, timezone

import yaml
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()

from fetchers import (
    fetch_rss, fetch_sitemap, fetch_podcast, fetch_youtube,
    fetch_scholarly, fetch_scholarly_rss, fetch_scholarly_authors,
    present, DEFAULT_PRESENT_MODEL,
)


FETCHERS = {
    "rss":               fetch_rss,
    "sitemap":           fetch_sitemap,
    "podcast":           fetch_podcast,
    "youtube":           fetch_youtube,
    "scholarly":         fetch_scholarly,
    "scholarly_rss":     fetch_scholarly_rss,
    "scholarly_authors": fetch_scholarly_authors,
}


def load_config(path: str = "feeds.yaml") -> dict:
    with open(path) as f:
        return yaml.safe_load(f)


def get_supabase() -> Client:
    url = os.environ.get("SUPABASE_URL")
    key = os.environ.get("SUPABASE_SERVICE_KEY") or os.environ.get("SUPABASE_KEY")
    if not url or not key:
        print("ERROR: SUPABASE_URL and SUPABASE_SERVICE_KEY must be set", file=sys.stderr)
        sys.exit(1)
    return create_client(url, key)


def load_seen_urls(sb: Client, source_id: str, limit: int = 5000) -> set[str]:
    """Pull recent URLs for this source so the fetcher can skip duplicates cheaply.
    The DB has a UNIQUE constraint on url as the real safety net."""
    resp = (
        sb.table("articles")
          .select("url")
          .eq("source_id", source_id)
          .order("fetched_at", desc=True)
          .limit(limit)
          .execute()
    )
    return {row["url"] for row in (resp.data or [])}


def upsert_article(sb: Client, article: dict, present_model: str) -> bool:
    dt = article.get("date")
    published_at = dt.isoformat() if hasattr(dt, "isoformat") else None

    summary = article.get("summary")
    card_teaser = None
    card_teaser_model = None
    # Presentation pass only runs when summarization succeeded — without a
    # summary there's nothing to rewrite, and resummarize_pending.py will
    # pick this row up later (which will also backfill the teaser).
    if summary:
        card_teaser = present(
            summary,
            title=article.get("title") or "",
            source_type=article.get("source_type") or "rss",
            model=present_model,
        )
        if card_teaser:
            card_teaser_model = present_model

    row = {
        "url":               article["url"],
        "title":             article.get("title"),
        "source_id":         article["source_id"],
        "source_name":       article.get("source_name"),
        "source_type":       article.get("source_type"),
        "published_at":      published_at,
        "summary":           summary,
        "card_teaser":       card_teaser,
        "card_teaser_model": card_teaser_model,
        "read_minutes":      article.get("read_minutes"),
    }

    try:
        sb.table("articles").upsert(row, on_conflict="url").execute()
        return True
    except Exception as e:
        print(f"    Upsert error for {article['url']}: {e}")
        return False


def record_run(sb: Client, source_id: str, ok: bool, new_count: int, error: str | None):
    try:
        sb.table("source_runs").insert({
            "source_id": source_id,
            "ok":        ok,
            "new_count": new_count,
            "error":     error,
        }).execute()
    except Exception as e:
        print(f"    Failed to record run for {source_id}: {e}")


def process_source(sb: Client, source: dict, settings: dict) -> tuple[int, str | None]:
    sid = source["id"]
    source_type = source.get("type", "rss")
    fetcher = FETCHERS.get(source_type)
    if not fetcher:
        return 0, f"Unknown source type: {source_type}"

    seen = load_seen_urls(sb, sid)

    try:
        articles = fetcher(source, seen, settings)
    except Exception as e:
        return 0, str(e)

    present_model = settings.get("presentation_model", DEFAULT_PRESENT_MODEL)

    count = 0
    for article in articles:
        if upsert_article(sb, article, present_model):
            count += 1
    return count, None


def main():
    config = load_config()
    settings = config.get("settings", {})
    sources = config.get("sources", [])
    sb = get_supabase()

    print(f"=== Sourcerer Pull @ {datetime.now(timezone.utc).isoformat()} ===")
    print(f"Sources: {len(sources)}")
    print(f"Lookback: {settings.get('lookback_days', 3)} days")
    print()

    total_new = 0
    errors = []

    for source in sources:
        sid = source["id"]
        print(f"[{sid}]")

        count, error = process_source(sb, source, settings)

        if error:
            print(f"  ERROR: {error}")
            errors.append((sid, error))
            record_run(sb, sid, ok=False, new_count=0, error=error)
        else:
            print(f"  OK: {count} new articles")
            total_new += count
            record_run(sb, sid, ok=True, new_count=count, error=None)
        print()

    print(f"=== Done ===")
    print(f"New articles: {total_new}")
    if errors:
        print(f"Errors: {len(errors)}")
        for sid, err in errors:
            print(f"  {sid}: {err}")

    if errors and len(errors) == len(sources):
        sys.exit(1)


if __name__ == "__main__":
    main()
