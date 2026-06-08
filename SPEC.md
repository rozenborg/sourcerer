# Sourcerer Spec

The product spec, organized by capability. Each section: **Vision** (what
we want it to be) → **Today** (what exists now, with status tags) →
**Gaps** (known unimplemented work) → **Disposition** (what to do next).

This is the source of truth for what Sourcerer *is becoming*. Implementation
should match what's here; if implementation drifts, update the spec.

**Status tags** (used in *Today* lists)
- `[delight]` — works well, feels good
- `[ok]` — works, nothing to flag
- `[ux]` — works, UX issues (copy, layout, friction)
- `[bug]` — works mostly, has bugs
- `[broken]` — doesn't work
- `[stub]` — known placeholder; UI surface only, no backend
- `[?]` — untested

---

# Part 1 — The pipeline (Sourcerer the engine)

## Source ingestion

**Vision.** A headless content database. Once a source is in `feeds.yaml`,
the daily cron fetches it, summarizes via Gemini Flash (with a Sonnet
fallback for transient failures), and upserts into Supabase. Any consumer
(iOS, MCP, dashboards) reads from there. Plain functions, no classes,
no framework — the simplicity is intentional.

**Today.**
- `[delight]` Seven fetcher types: `fetch_rss`, `fetch_sitemap`,
  `fetch_podcast`, `fetch_youtube`, `fetch_scholarly`,
  `fetch_scholarly_rss`, `fetch_scholarly_authors`. Dispatched via the
  `FETCHERS` dict in [pull.py](pull.py).
- `[delight]` Per-source `seen_urls` dedup before paying for the LLM.
- `[delight]` `source_runs` row written per source per run; `source_health`
  view shows latest run per source.
- `[delight]` Comprehensive single-sentence prompt locked in after a
  bake-off across Haiku 4.5, Sonnet 4.6, Gemini 2.5 Flash (thinking on/
  off), and Flash-Lite. Gemini Flash chosen on cost-quality (~8× cheaper
  than Sonnet at comparable depth). `thinking_budget=0` to avoid
  silently consuming `max_output_tokens` on reasoning.
- `[delight]` Two-cron retry pattern for transient Gemini outages:
  - `daily.yaml` at 08:00 UTC inserts `summary IS NULL` on failure
    (no in-run retry; faster overall ingest).
  - `resummarize.yaml` at 09:00 UTC runs `resummarize_pending.py`,
    re-extracts via trafilatura, tries Gemini → falls back to Sonnet.
  - iOS `feed_articles` view hides NULL summaries so users never see
    half-empty cards while items are pending.
- `[ok]` Substack/CF-protected feeds wrapped via own Cloudflare worker
  (`substack-proxy.rozenborg.workers.dev`).
- `[bug]` **YouTube cookies expire every 1–3 days** under datacenter-IP
  access. When YouTube ingest stops working, `YOUTUBE_COOKIES` GitHub
  secret needs re-export. See CLAUDE.md for the runbook.
- `[bug]` **Sibling worker has drifted**. `workers/summarize-api/worker.js`
  (in a separate repo) historically duplicated the in-repo prompt. The
  in-repo prompt is now completely different (comprehensive single-
  sentence → Gemini Flash); the worker still runs the legacy
  Sonnet-with-HEADLINE-and-bullets shape. If the worker is in active use
  anywhere, it's producing the old format. Sync or retire it.
- `[bug]` **Resummarization loses Mollick rationale**. Scholarly fetchers
  prepend `_Mollick-likeness: NN/20 — reason_` to the summary at ingest
  time. When the resummarize cron regenerates a summary, that prefix is
  lost (we don't store score/reason as separate columns). Acceptable for
  now since (a) ParsedSummary in iOS already strips the prefix at render,
  and (b) the iOS UI doesn't use the rationale today.
- `[bug]` **Podcast / YouTube can't be re-summarized**. The retry cron
  uses trafilatura on the article URL, which doesn't work for podcast
  audio or YouTube videos (those need transcript regeneration). If
  Gemini fails on a podcast/youtube article, it stays NULL until the
  next daily run picks it up via dedup pressure.

**Gaps.**
- Whisper fallback for YouTube videos with captions disabled.
- Podcast transcript routing — check shownotes for transcripts before
  downloading audio.
- Transcript-source re-summarization (podcast/youtube) for the retry job.
- Storing Mollick score + reason as columns so they survive re-summarization
  and become available for ranking/display.

**Disposition.**
- Cookie refresh is the recurring tax — move to a self-hosted runner with
  a residential IP would kill the problem permanently. Until then, keep
  it manual.
- Sibling worker drift: either sync the new prompt + Gemini call to the
  worker, or formally retire it. Defer.

## Adding sources

**Vision.** Paste a name or URL, get a working entry in `feeds.yaml`. Three
layers: (1) more source types, (2) URL-based auto-add, (3) name-based
discovery. Layers 1–2 mostly shipped; layer 3 is future.

**Today.**
- `[delight]` `python add_source.py <url>` — probes a URL, detects type,
  runs lightweight preview (no Claude/Whisper calls), appends to
  `feeds.yaml`.
- `[delight]` Auto-handles: RSS discovery (`<link rel="alternate">`),
  common fallback paths (`/feed`, `/rss`, `/atom`), podcast vs article
  detection via `<enclosure>`, YouTube channel/handle URLs, Apple Podcasts
  → iTunes Search API, Substack proxy-wrapping.
- `[stub]` Sitemap fallback (pull from `robots.txt`, ask Claude to suggest
  a `url_pattern`).
- `[stub]` Auto-decide whether a feed needs a `keywords` filter.
- `[stub]` `add_source.py` doesn't yet handle the three `scholarly` source
  types — those are still hand-edited in `feeds.yaml`.

**Gaps.**
- Layer 3 (name-based discovery): "the sequoia capital youtube channel" →
  candidate feeds across YouTube/iTunes/web. Multi-surface entities
  (Sequoia = YouTube + 2 podcasts + blog) get a "pick which surfaces"
  picker.

**Disposition.** Layer 1–2 polish (sitemap fallback, keyword auto-decide,
scholarly support) is incremental. Layer 3 is a real product surface —
worth its own spec section when picked up.

## Scholarly filtering (Mollick-style)

**Vision.** Pull in research papers that match a specific editorial taste
(Ethan Mollick's — empirical, human-in-the-loop AI, decision-support).
Score every candidate against a rubric; only summarize the ones that pass.

**Today.**
- `[delight]` Four sources running: S2 recommender (seeded from JSONL
  bundle), NBER feed, arXiv (`cs.HC` + `cs.CY`), full author watchlist.
- `[delight]` Mollick-likeness 0–20 rubric inlined in
  `MOLLICK_RUBRIC_PROMPT`, scored by Claude Haiku, threshold default 12.
- `[delight]` Seed bundle in
  `reference_material/ethan_mollick_seed_corpus_ids_bundle/` — ~100
  verified S2 paperIds. Dodges title-search rate limit at runtime.
- `[delight]` Watchlist bypass — `scholarly_authors` pulls every recent
  paper by named researchers, no scoring filter.
- `[bug]` **Name-collision false positives.** "Sida Peng" matches both a
  Microsoft dev-productivity researcher AND an ML/CV researcher; the
  "pick most prolific" heuristic chose wrong on first run. Fix per
  collision: pin the right `authorId` in `feeds.yaml`.
- `[ok]` SSRN is officially dead-ended (Elsevier killed the public RSS
  after acquiring SSRN). Watchlist replaces that coverage path.

**Gaps.**
- §11 hype penalty (deduct 0–3 for benchmark-only, no human baseline,
  vendor marketing, overclaiming) not yet in the rubric.
- 34 UNRESOLVED rows in the seed bundle still need lookup.
- Auto-discover new seed papers — when Mollick himself cites a paper
  that scores well, auto-add to seeds.
- JAMA / NEJM AI / Nature Medicine RSS for medical AI decision-support
  evidence.

**Disposition.** Filter is mostly mature. Next concrete win is the hype
penalty (one prompt change). AuthorId pinning is one-time per offender.

---

# Part 2 — The iOS app

**Refocused 2026-06-08.** The 2026-05-24 rebuild fanned out to five tabs
(Today / Tomorrow / Deck / Brief / Me) layered on aspirational backend
that didn't exist yet — half-implemented surfaces that set dishonest
expectations. We stripped back to the core loop and will add surfaces
back as the backend earns them.

**Two tabs now: Today / Me.** Reads from the same Supabase the pipeline
writes to; layers per-user skip / save (triage) + a separate ratings
signal on top.

The core loop, in three depths plus a learning signal:
1. **Skim** — the daily deck of cards; triage by swipe.
2. **One tap deeper** — the article detail (longer summary).
3. **Two taps deeper** — "Open original" to the source.
4. **Rate** — stars + note, captured for tuning the feed over time.

> Several views' code comments reference a `PRODUCT_SPEC` document that
> doesn't exist in the repo. This file is now that doc. Where vision
> statements below cite "PRODUCT_SPEC §N", they're drawn from those
> comments; expand as we firm them up.

## Today — the daily deck ritual

**Vision.** The day's fresh content, shaped for completion. A bounded
deck (the day's batch, not an unbounded backlog) you triage with intent.
Two modes over the same set: DECK (card-pile, gesture-driven, tactile)
and LIST (dense, scannable). The deck has a natural end — light days are
short, heavy days longer — so clearing it feels finite.

**The gesture model (triage economy).** The deck is a *fast triage*
surface, nothing heavier:
- **← skip** → `passed_at`. Not for me, gone from the deck.
- **→ save** → `saved_at`. Keep it; surfaces in the Me tab.
- **↑ postpone** → no persistence. Reshuffles the card ~10 deeper —
  "ask me later." Session-scoped: if the deck ages out before you return,
  it ages out like everything else (this is the valve that keeps Save
  from becoming a dumping ground / second pile).
- **tap** → open detail (the longer summary).
- Rating is deliberately **not** a deck gesture — it's a considered act
  that lives in the detail view, after you've actually engaged.

**Today.**
- `[?]` Card pile renders top 3 with depth scale/rotation; top card is
  draggable. Swipe-intent badges (SKIP / SAVE / LATER) fade in during
  drag; snap-back if threshold isn't met.
- `[?]` DECK ↔ LIST toggle in header; LIST mode is a dense scannable
  variant with status per row.
- `[?]` Deck bounded to a recent window (48h) via `listFeed(since:)`,
  with a 250-row query ceiling as a safety limit (not a UX cap).
- `[?]` Source-interleave so no single source clusters at the front.
- `[?]` Empty state ("today's deck is clear · pull to refresh") when
  cleared — no longer promises a 06:30 briefing.
- `[stub]` **Cleared state is local-only** — `@State` set, lost on relaunch.
- `[stub]` **Not a server-curated "deck of the day"** — slices the recent
  feed. No server-side per-day deck build.

**Gaps.**
- Server-side daily deck build job (cron picks the day's deck based on
  the user's rating signal).
- `daily_session` schema for persisted clear-state and the cleared/total
  counter.
- Card numbering ("no. 04 / NN") is position among remaining, not the
  original deck order — needs deck-build to know original order.

**Disposition.** This is the heart of the app. Highest-priority fix:
persist clear-state (so skip/save/postpone survive relaunch). Server-side
curated deck is the bigger architectural lift.

## Me ("Profile" tab) — the record of what you kept

**Vision.** A simple, honest record: everything you've saved, newest
first. The longitudinal view (activity grid, streaks, milestones) was
stripped — it ran on faked/proxy data — and returns once real
`daily_session` aggregates exist.

**Today.**
- `[?]` List of all saved articles via `listSaved(limit: 200)`; tap row →
  ArticleDetailView.
- `[?]` Honest empty state ("nothing saved yet · swipe a card right").
- `[?]` Settings behind the gear (top-right).

**Gaps.**
- Pagination beyond 200 saved.
- A view of *rated* items (the ratings dataset) once we decide how to
  surface it.

**Disposition.** Deliberately minimal. The longitudinal grid/milestones
come back when `daily_session` makes them honest.

## Parked surfaces (stripped in the 2026-06-08 refocus)

These shipped as UI in the 2026-05-24 rebuild but ran ahead of the
backend. Removed from the app (view files deleted) to protect the core
loop; the vision is preserved here for when the backend earns them back.

- **Tomorrow — staged for 06:30** (was PRODUCT_SPEC §6). Tomorrow's deck
  visible the night before: saved-but-unread + overnight follow-ups
  picked from what you rated. Needs an overnight deck-build cron that
  doesn't exist. Was showing today's saves + hardcoded fake follow-up
  chips + hardcoded 4★ rows.
- **Library / "Deck" tab — curated decks** (was PRODUCT_SPEC §5). The
  user's collection: default Saved/Sparked decks plus user-curated named
  decks, "Add to deck" sheet, notes/highlights. The "+ NEW DECK" buttons
  were dead (empty closures) and Archive was a placeholder. Saved content
  now lives in the simpler Me tab.
- **Brief — audio briefing** (was PRODUCT_SPEC Phase 4). A ~5-minute
  audio briefing generated overnight from your top-rated items, threaded
  into a narrative. The "TAP TO SCRY" orb did nothing; no script
  generator, no TTS, no playback. The most aspirational surface.

**Disposition.** Each is a real product idea, not abandoned — but each
needs a server-side job (deck-build cron, briefing generator) before its
UI is anything but promissory. Revisit once the rating dataset and a
curated deck-build job exist; the rating signal is the prerequisite that
makes Tomorrow's re-rank and the Brief's thread possible.

## Article detail (modal from any list)

**Vision.** The reading surface for a single article — and the home of
rating. Topic chip + title + parsed headline + markdown body + action row
(Skip / Rate / Save) + "Open original" CTA. Tap Rate → opens RatingSheet.

**Today.**
- `[?]` Topic chip + prefix tag (parsed from summary).
- `[?]` Display title in italic display font; headline below.
- `[?]` Markdown body via MarkdownUI 2.4 (`.markdownTheme(.basic)`).
- `[?]` Action row: Skip / Save toggle `article_interactions`; Rate opens
  the RatingSheet and persists to `article_ratings` (shows "Rated" once set).
- `[?]` "Open original" CTA (cobalt with glow shadow).

**Gaps.** None major — this surface is mostly complete.

**Disposition.** Watch for typography/spacing inconsistencies vs Today
once we triage the design system.

## Rating system

**Vision.** Rate a piece you've engaged with: stars + an open-form note.
A **research dataset first, a tuning input second** — the goal is honest
capture of what the user actually thinks, in their own words. Lives in
the detail view (a considered act), never on a deck swipe.

The **"unlock"**: preset reason chips were removed because the original
9 were guessed up front and didn't match how the user thinks. Instead,
once enough substantive notes exist, we analyze them to surface the
user's *own* recurring themes and offer those back as quick-tap chips —
earned vocabulary, not invented. Not built yet; the `reasons[]` column
is reserved so the dataset is shaped for it from day one.

**Today.**
- `[delight]` `article_ratings` table shipped (migration
  `20260608000000_article_ratings.sql`): stars (1–5), note, rated_at,
  reserved reasons[], one row per user/article, RLS-scoped. Re-rating
  upserts.
- `[?]` RatingSheet: 5-star with phrase per level (skip / meh / decent /
  worth it / essential) + optional open-form note. Single submit. Pre-fills
  on re-rate. Persisted via `RatingsRepository`.
- `[?]` Detail-view "Rate" action (shows "Rated" once set).

**Gaps.**
- The note→chip "unlock" analysis (batch job over a user's notes).
- Re-rank logic that consumes ratings (intentionally deferred — capture
  first).
- A surface to review your own ratings/notes.

**Disposition.** Capture is now honest. Next concrete steps are
deferred-by-design: accumulate notes, then build the unlock. Re-ranking
is a later phase once we know what signal is worth training on.

## Settings

**Vision.** Toggles for things the user actually controls. A toggle
appears only once the behavior behind it is wired.

**Today.**
- `[ok]` Sign out (with confirmation dialog).
- Pared to the account section in the refocus — the old deck / briefing /
  rating toggle banks were removed. They persisted to `@AppStorage` but
  were never read, and most named features that no longer exist (ticker,
  audio briefing, re-rank).
- `[stub]` **No account deletion** (required for App Store —
  Guideline 5.1.1(v)).

**Gaps.**
- Account deletion flow (blocking public App Store, not TestFlight).
- Re-introduce toggles as their behaviors ship.

**Disposition.** Honest-minimal. Account deletion is an App Store
submission blocker, not a TestFlight blocker.

## Auth

**Vision.** Apple + email sign-in. Native Sign in with Apple via
`signInWithIdToken`; email as fallback.

**Today.** Phase 1 — shipped, didn't change with the UX rebuild.

**Gaps.** Account deletion (see Settings).

**Disposition.** Stable. Don't touch unless deletion flow lands.

## Design system

**Vision.** A consistent visual language across all surfaces. Paper-palette
backgrounds, ink/cobalt typography, topic colors, orb mark. Cards and
rows are reusable; everything composes from the same primitives.

**Today.**
- `[?]` PageBackground (atmospheres: calm, dawn).
- `[?]` Theme.Typography scales (display / serif / body / meta).
- `[?]` Theme.Color palette (stone / ink / accent / sage).
- `[?]` Components: TopicChip, OrbView, BriefingOrb (auth screen),
  SparkStars, StatusPill, DeckCard, ListRowCard, PageMasthead, ModeToggle.
  (TickerBar and StreakRibbon were removed in the refocus.)

**Disposition.** Triage from the iOS surfaces above — if a typography or
spacing bug shows up in multiple tabs, fix at the component level here
rather than tab-by-tab.

---

# Part 3 — iOS submission readiness

Not blocking TestFlight; blocking public App Store.

- `[stub]` Account deletion flow — Apple Guideline 5.1.1(v).
- `[stub]` App Store listing: screenshots, description, privacy policy
  URL, support URL, age rating.
- `[ok]` Privacy Manifest (`PrivacyInfo.xcprivacy`) — shipped.
- `[ok]` TestFlight runbook in [ios/README.md](ios/README.md).

---

# Part 4 — Extraction (when ready)

The `ios/` directory will move to `rozenborg/sourcerer-ios` once the app
is stable. Trigger: pipeline and client cadences want to diverge.
Procedure documented in [ios/README.md](ios/README.md#extraction-when-ready).

`git subtree split --prefix=ios` preserves file history.
