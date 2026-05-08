# Sourcerer

Headless content database. GitHub Actions cron fetches sources in `feeds.yaml`, summarizes via Claude, upserts into Supabase.

## How runs happen

- **Production**: GitHub Actions cron (`.github/workflows/daily.yaml`). Secrets (`SUPABASE_URL`, `SUPABASE_SERVICE_KEY`, `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`) live in repo settings.
- **Local**: `python pull.py` after `pip install -r requirements.txt`. Reads `.env` via `python-dotenv`. `.env` is gitignored — never commit it.

## Non-obvious things

- **Substack proxy**: `substack-proxy.rozenborg.workers.dev` is our own Cloudflare worker, not a third-party service. Substack/Cloudflare-protected feeds must be wrapped with it (see existing entries in `feeds.yaml`).
- **Sibling worker**: `fetchers.py` references `workers/summarize-api/worker.js` (a separate Cloudflare worker). The summarization prompt is duplicated between `summarize()` in `fetchers.py` and the worker — keep them in sync if either changes.
- **Supabase URL**: it's `https://<project-id>.supabase.co` (API endpoint), **not** `https://supabase.com/dashboard/project/<project-id>` (dashboard UI). Easy mistake when copying from the browser.

## Code style

Plain functions, no classes, no framework. Fetchers (`fetch_rss`, `fetch_sitemap`, `fetch_podcast`, `fetch_youtube`) dispatched via the `FETCHERS` dict in `pull.py`. The simplicity is intentional — don't refactor toward abstractions. New fetchers should follow the same shape: `fetch_X(source, seen_urls, settings) -> list[article_dict]`.

The `youtube` fetcher uses yt-dlp for everything — listing channel videos AND discovering caption track URLs. The `android` player_client is pinned because the `web` client returns empty subtitle dicts in CI, and `youtube-transcript-api` is IP-blocked from datacenter ranges (verified failing on GitHub Actions). Captions come back as json3 fetched directly via httpx. Videos without captions are skipped — Whisper fallback is on the wishlist. Lookback filtering doesn't apply to YouTube (flat extraction lacks per-video timestamps); `max_posts_per_source` and seen-URL dedup are the limiters.

The `scholarly` fetcher uses Semantic Scholar's recommendation API seeded with curated "taste" papers (see `feeds.yaml`), then runs each candidate through a Claude Haiku call that scores Mollick-likeness 0-20 against the rubric inlined in `MOLLICK_RUBRIC_PROMPT`. Only papers ≥ `score_threshold` (default 12) get summarized via Sonnet and ingested.

The `scholarly_rss` fetcher applies the same Mollick-likeness rubric to academic RSS feeds — currently NBER's new-papers feed and arXiv (`cs.HC`, `cs.CY`). The cs.AI firehose is intentionally excluded (~500 entries/day = expensive scoring with low yield). SSRN was the original target here but Elsevier deprecated their public eJournal RSS after acquiring SSRN; the site is anti-bot and that ecosystem is genuinely unreachable without scraping.

## Adding sources

`python add_source.py <url> [--name "..."] [--id slug] [--keywords AI LLM] [--dry-run]` probes a URL, detects the right fetcher type (rss/podcast/youtube/sitemap), runs a lightweight preview (no Claude/Whisper calls), and appends to `feeds.yaml`. Handles RSS auto-discovery, Apple Podcasts (via iTunes Search API), YouTube channels, and Substack proxy-wrapping automatically.

## Wishlist

Ideas and unfinished work live in [WISHLIST.md](WISHLIST.md). Check items off there as they ship.
