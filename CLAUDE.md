# CLAUDE.md

Guidance for Claude Code when working in this repository.

> For *what we're building and why*, see [SPEC.md](SPEC.md). This file
> covers *how the code is shaped* and *non-obvious gotchas* — engineering
> context that doesn't belong in a product spec.

# Sourcerer

Headless content database. GitHub Actions cron fetches sources in
`feeds.yaml`, summarizes via Gemini 2.5 Flash (with a Sonnet fallback
for transient failures), upserts into Supabase. The pipeline is the
source of truth; any consumer (iOS app, MCP servers, dashboards) reads
from Supabase.

Pipeline shape: `feeds.yaml → pull.py → fetchers.py (FETCHERS dispatch
+ summarize via Gemini) → Supabase.articles`. `pull.py` is the thin
orchestrator that loads `feeds.yaml`, fetches the per-source `seen_urls`
set from Supabase, dispatches by `type`, and upserts results with a
`source_runs` row per source.

## How runs happen

- **Production**: two GitHub Actions crons:
  - `.github/workflows/daily.yaml` — 08:00 UTC, the main ingest.
  - `.github/workflows/resummarize.yaml` — 09:00 UTC, picks up
    `summary IS NULL` rows from the morning run and retries (Gemini →
    Sonnet fallback). Decoupled so a transient Gemini outage during
    ingest doesn't cost the article.
  Secrets (`GEMINI_API_KEY`, `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`,
  `SUPABASE_URL`, `SUPABASE_SERVICE_KEY`) live in repo settings.
- **Local**: `python pull.py` after `pip install -r requirements.txt`.
  Reads `.env` via `python-dotenv`. `.env` is gitignored — never commit
  it. To retry NULL summaries locally: `python resummarize_pending.py`.

## Non-obvious things

- **Substack proxy**: `substack-proxy.rozenborg.workers.dev` is our own
  Cloudflare worker, not a third-party service. Substack/Cloudflare-protected
  feeds must be wrapped with it (see existing entries in `feeds.yaml`).
- **Sibling worker (now drifted)**: a sibling repo houses
  `workers/summarize-api/worker.js` which historically duplicated the
  in-repo `summarize()` prompt. As of the Gemini migration, the in-repo
  prompt is completely different (single-sentence "Capture the full
  substance of this piece..." → Gemini Flash) while the worker still
  runs the old Sonnet-with-HEADLINE-and-bullets shape. If the worker is
  still in active use anywhere, it's producing the legacy format.
- **Summarizer dispatch**: `summarize()` in `fetchers.py` routes by model
  name prefix — `gemini-*` → Gemini API, anything else → Anthropic API.
  This is intentional so `summarization_model` in `feeds.yaml` (and the
  `summarization_fallback_model` used by `resummarize_pending.py`) can
  cross providers without a separate `provider:` setting.
- **Gemini 2.5 thinking is OFF for summarization** (`thinking_budget=0`).
  With the default dynamic budget, Gemini silently spends most of
  `max_output_tokens` on internal reasoning before producing visible
  text — yielding 100-token summaries on a 3000-token budget. Bug
  reproduced consistently on the attention.pdf test case during the
  prompt bake-off. Not relevant for summarization quality; the cost is
  real reliability.
- **Supabase view default is unsafe**: Postgres views default to running
  with the *creator's* permissions, bypassing RLS. Supabase Advisor
  flags this as "Security Definer View". Always add
  `with (security_invoker = true)` when creating a view. Example in
  `ios/supabase/migrations/20260528000000_feed_articles_hide_null_summary.sql`.
- **Postgres `select *` in views is resolved at CREATE TIME**, not query
  time. `CREATE VIEW v AS SELECT a.*` snapshots the column list at the
  moment of creation; adding columns to `articles` later does NOT
  propagate to the view. After adding columns to `articles` you must
  `DROP VIEW; CREATE VIEW;` to expose them via `feed_articles`. Bit us
  when `card_teaser` was added — iOS got no error, just silently null
  values. Fix pattern in `ios/supabase/migrations/20260530000001_recreate_feed_articles_for_card_teaser.sql`.
- **Supabase URL**: it's `https://<project-id>.supabase.co` (API endpoint),
  **not** `https://supabase.com/dashboard/project/<project-id>` (dashboard
  UI). Easy mistake when copying from the browser.

## Code style

Plain functions, no classes, no framework. Seven fetcher types —
`fetch_rss`, `fetch_sitemap`, `fetch_podcast`, `fetch_youtube`,
`fetch_scholarly`, `fetch_scholarly_rss`, `fetch_scholarly_authors` —
dispatched via the `FETCHERS` dict in `pull.py`. The simplicity is
intentional — don't refactor toward abstractions. New fetchers should
follow the same shape: `fetch_X(source, seen_urls, settings) -> list[article_dict]`.

## Fetcher-specific gotchas

### YouTube

The `youtube` fetcher uses yt-dlp for everything — listing channel videos
AND discovering caption track URLs. The `android` player_client is pinned
because the `web` client returns empty subtitle dicts in CI, and
`youtube-transcript-api` is IP-blocked from datacenter ranges (verified
failing on GitHub Actions). Captions come back as json3 fetched directly
via httpx. Videos without captions are skipped — Whisper fallback is a
known gap. Lookback filtering doesn't apply to YouTube (flat extraction
lacks per-video timestamps); `max_posts_per_source` and seen-URL dedup
are the limiters.

**Cookies (recurring tax).** `YOUTUBE_COOKIES` GitHub secret expires
every 1–3 days under datacenter-IP access. When YouTube ingest stops
working, re-export cookies and `gh secret set YOUTUBE_COOKIES < cookies.txt`.
Permanent fix: self-hosted runner with a residential IP.

### Scholarly

The `scholarly` fetcher uses Semantic Scholar's recommendation API seeded
with curated "taste" papers, then runs each candidate through a Claude
Haiku call that scores Mollick-likeness 0–20 against the rubric inlined
in `MOLLICK_RUBRIC_PROMPT`. Only papers ≥ `score_threshold` (default 12)
get summarized via Sonnet and ingested. Seeds load from a pre-resolved
JSONL bundle (`reference_material/ethan_mollick_seed_corpus_ids_bundle/...jsonl`)
which has ~100 verified S2 paperIds — this dodges S2's aggressive
title-search rate limit. Inline `seed_papers` in `feeds.yaml` is supported
as overflow for new seeds added outside the bundle.

The `scholarly_rss` fetcher applies the same Mollick-likeness rubric to
academic RSS feeds — currently NBER's new-papers feed and arXiv (`cs.HC`,
`cs.CY`). The cs.AI firehose is intentionally excluded (~500 entries/day
= expensive scoring with low yield). SSRN was the original target but
Elsevier deprecated their public eJournal RSS after acquiring SSRN; that
ecosystem is genuinely unreachable without scraping.

The `scholarly_authors` fetcher pulls **every** recent paper by named
researchers via S2's author/papers endpoint — no scoring filter, full
coverage. Watchlist authors come from §8 of the Mollick reference doc.

**Known operational issue — name collisions.** "Sida Peng" matches both
a Microsoft developer-productivity researcher AND a separate ML/CV
researcher; the "pick most prolific" heuristic chose the wrong one in
our first run. Fix when it bites: pin the right `authorId` directly in
`feeds.yaml` (S2 endpoint accepts authorId in lieu of name).

## Adding sources

`python add_source.py <url> [--name "..."] [--id slug] [--keywords AI LLM] [--dry-run]`
probes a URL, detects the right fetcher type (rss/podcast/youtube/sitemap),
runs a lightweight preview (no Claude/Whisper calls), and appends to
`feeds.yaml`. Handles RSS auto-discovery, Apple Podcasts (via iTunes
Search API), YouTube channels, and Substack proxy-wrapping automatically.
**Does not yet support** the scholarly source types — those are configured
by editing `feeds.yaml` directly.

## Reference material

The `reference_material/` directory holds context docs that shape how
Sourcerer filters scholarly content:

- `mollick_style_ai_research_monitoring_reference.md` — the 0–20
  Mollick-likeness scoring rubric (§9.1) inlined in
  `MOLLICK_RUBRIC_PROMPT`, plus topical lane definitions.
- `ethan_mollick_semantic_scholar_seed_corpus.md` — the deeper reference
  with §6 thematic clusters, §7 highest-value 40 list, §8 author
  watchlist, §11 alternate scoring rubric.
- `ethan_mollick_seed_corpus_ids_bundle/` — the pre-resolved canonical
  IDs bundle the `scholarly` fetcher loads via `seed_jsonl`. Contains a
  CSV/MD/JSONL trio plus `semantic_scholar_bulk_resolver.py` for
  resolving the remaining UNRESOLVED rows.

# iOS app

The `ios/` directory holds a SwiftUI client (`SourcererApp`) that reads
from the same Supabase project the pipeline writes to and layers per-user
pass/spark/save on top. It currently lives in this repo while being
stabilized and will be extracted to `sourcerer-ios` later. Setup, project
generation (`xcodegen` from `project.yml`), and Supabase migration steps
(`ios/supabase/migrations/`) live in [ios/README.md](ios/README.md). The
pipeline does not depend on the iOS app — pipeline-only changes should
not touch `ios/`.

The canonical pipeline schema is `schema.sql` at the repo root
(`articles`, `source_runs`, `source_health` view).
`ios/supabase/migrations/` is additive user-state on top of that.

## App shape (post-rebuild)

`@main SourcererApp` → `RootView` → either `AuthView` or `RootTabView`
(5 tabs: Today / Tomorrow / Deck / Brief / Me). Each tab is a `*View.swift`
under `Views/<TabName>/`. `AppEnvironment` is the DI container;
`ArticleRepository`, `InteractionsRepository`, `AuthService` are the
services.

Design system lives under `DesignSystem/` — `SourcererTheme.swift` for
typography/color, `Components/` for reusable UI (DeckCard, ListRowCard,
OrbView, TickerBar, etc.). If a visual bug shows up in multiple tabs,
fix it at the component level rather than tab-by-tab.

## iOS-specific gotchas

- **Launch-arg debug preview.** To inspect SwiftUI screens before auth
  is wired, state is gated on `ProcessInfo.processInfo.arguments` inside
  `#if DEBUG`. Launch via
  `xcrun simctl launch <device> com.rozenborg.sourcerer --preview --tab=N`.
  Strips cleanly in Release. Already wired in `SourcererApp.swift` and
  `RootTabView.initialTab()`.

- **Snapshot loops** via `xcrun simctl io <device> screenshot path.png`
  beat opening the Simulator GUI for each tab. Combine with
  `xcrun simctl terminate` + relaunch with different launch args to
  capture every screen state. Default iPhone names drift across Xcode
  releases — `xcrun simctl list devices` to find the current name (in
  iOS 26.x it's "iPhone 17 Pro").

- **MarkdownUI text color.** `.markdownTheme(.basic)` doesn't set text
  color — it inherits the SwiftUI environment, which on our paper
  palette can resolve to white-on-cream (unreadable). SwiftUI's
  `.foregroundStyle(...)` modifier does **not** penetrate MarkdownUI's
  internal text rendering. Use the library's own builder API:
  `.markdownTextStyle { ForegroundColor(Theme.Color.ink) }`. The
  `ForegroundColor`, `FontFamily`, `FontSize`, etc. builders all exist
  in the installed version (`Sources/MarkdownUI/Theme/TextStyle/Styles/`).
  Used in `ArticleDetailView`.

- **`PRODUCT_SPEC` references in view comments** point to
  [SPEC.md](SPEC.md). The numbered sections in code comments (§1, §3,
  §5, §6, Phase 2, Phase 4) predate the spec being written and may not
  line up perfectly with current SPEC.md sections — treat them as
  historical intent markers, not authoritative section refs.
