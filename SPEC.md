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
the daily cron fetches it, summarizes via Claude, and upserts into
Supabase. Any consumer (iOS, MCP, dashboards) reads from there. Plain
functions, no classes, no framework — the simplicity is intentional.

**Today.**
- `[delight]` Seven fetcher types: `fetch_rss`, `fetch_sitemap`,
  `fetch_podcast`, `fetch_youtube`, `fetch_scholarly`,
  `fetch_scholarly_rss`, `fetch_scholarly_authors`. Dispatched via the
  `FETCHERS` dict in [pull.py](pull.py).
- `[delight]` Per-source `seen_urls` dedup before paying for Claude.
- `[delight]` `source_runs` row written per source per run; `source_health`
  view shows latest run per source.
- `[ok]` GitHub Actions cron at 08:00 UTC daily
  ([.github/workflows/daily.yaml](.github/workflows/daily.yaml)).
- `[ok]` Substack/CF-protected feeds wrapped via own Cloudflare worker
  (`substack-proxy.rozenborg.workers.dev`).
- `[bug]` **YouTube cookies expire every 1–3 days** under datacenter-IP
  access. When YouTube ingest stops working, `YOUTUBE_COOKIES` GitHub
  secret needs re-export. See CLAUDE.md for the runbook.
- `[bug]` **Summarization prompt duplicated** between `summarize()` in
  [fetchers.py:344](fetchers.py#L344) and `workers/summarize-api/worker.js`
  in the sibling worker repo. Easy to drift.

**Gaps.**
- Whisper fallback for YouTube videos with captions disabled.
- Podcast transcript routing — check shownotes for transcripts before
  downloading audio.

**Disposition.**
- Cookie refresh is the recurring tax — move to a self-hosted runner with
  a residential IP would kill the problem permanently. Until then, keep
  it manual.
- Prompt duplication: either extract to a shared file (risks coupling two
  repos) or accept the drift and add a test that diffs them. Defer.

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

The new UX (rebuilt 2026-05-24). Five tabs: Today / Tomorrow / Deck /
Brief / Me. Reads from the same Supabase the pipeline writes to; layers
per-user pass / spark / save on top.

> Several views' code comments reference a `PRODUCT_SPEC` document that
> doesn't exist in the repo. This file is now that doc. Where vision
> statements below cite "PRODUCT_SPEC §N", they're drawn from those
> comments; expand as we firm them up.

## Today — the daily deck ritual

**Vision** (from PRODUCT_SPEC §1, §2). A bounded ~18-card daily deck the
user clears with intent. Two modes over the same set: DECK (card-pile,
gesture-driven, tactile) and LIST (dense, scannable). Each card cleared
counts toward the daily session arc. Cards aren't an inbox — they're a
day's reading shaped for completion.

**Today.**
- `[?]` Card pile renders top 3 with depth scale/rotation; top card is
  draggable. Swipe left = skip, right = save, up = deep/spark.
- `[?]` Swipe-intent badges (SKIP / SAVE / DEEP) fade in during drag;
  snap-back if threshold isn't met.
- `[?]` DECK ↔ LIST toggle in header; LIST mode is a dense scannable
  variant with status per row.
- `[?]` Ticker bar (flashing headline strip) above the deck.
- `[?]` Streak ribbon — currently `max(1, clearedIds.count)`, not a real
  streak.
- `[?]` Empty state ("today is done · come back tomorrow at 06:30") when
  deck cleared.
- `[stub]` **Cleared state is local-only** — `@State` set, lost on relaunch.
- `[stub]` **Not a real curated "deck of the day"** — slices the general
  feed to 18. No server-side per-day deck build.

**Gaps.**
- Server-side daily deck build job (06:30 cron picks ~18 from the past
  24h based on user's rating signal).
- `daily_session` schema for persisted clear-state, streak, and the
  cleared/total counter.
- Card numbering ("no. 04 / 18") should be position in the original deck,
  not position among remaining — needs deck-build to know original order.

**Disposition.** This is the heart of the app. Highest-priority fixes:
(1) persist clear-state, (2) make the streak real. Server-side curated
deck is the bigger architectural lift but unlocks Tomorrow and Briefing.

## Tomorrow — staged for 06:30

**Vision** (from PRODUCT_SPEC §6). What's going to be in tomorrow's deck,
visible the night before. Saved-but-unread items + 2 follow-ups Sourcerer
picks overnight based on what you sparked today. Sets the expectation
that tomorrow's deck is *built*, not random.

**Today.**
- `[?]` "From you · N saved" section pulls from `listSaved(limit: 50)`.
- `[?]` ETA card: "your saves + items Sourcerer is watching · final pick
  at 06:30".
- `[?]` Tap row → ArticleDetailView.
- `[stub]` **No 06:30 cron** — the view shows today's saves as stand-in
  for tomorrow's.
- `[stub]` **Follow-ups section is fake** — hardcoded chip strings
  ("AISI Q2 report", "Llama-4 update", etc.).
- `[stub]` **4★ stars on every row are hardcoded**, not real ratings.

**Gaps.**
- The overnight cron itself — picks follow-ups from sources/topics you
  sparked, builds the deck for 06:30.
- Real ratings on the staged rows.

**Disposition.** Until the cron exists, this view is mostly promissory.
Triage decision: kill the fake follow-up chips now (set false expectation),
or leave as a UI placeholder?

## Library ("Deck" tab) — decks of saved content

**Vision** (from PRODUCT_SPEC §5). The user's collection. Default decks
(Saved, Sparked) plus user-curated named decks (Phase 2). Items can live
in multiple decks; an "Add to deck" sheet appears from article detail.
Notes/highlights via `article_interactions.meta` (Phase 3).

**Today.**
- `[?]` Tab strip: Decks / Queue / Rated / Archive.
- `[?]` Decks tab: auto-generated "Saved" + "Sparked" tiles with
  bookshelf visual (two back-card peeks).
- `[?]` Queue tab = all saved articles; Rated tab = all sparked articles.
- `[?]` Tap deck → DeckListing.
- `[broken]` **"+ NEW DECK" button** (both the header pill and the dashed
  tile) — empty closures, no action.
- `[stub]` **Archive tab** — placeholder text only.
- `[stub]` **No "Add to deck" sheet** from article detail.

**Gaps.**
- User-curated named decks (create / rename / delete).
- "Add to deck" sheet.
- Notes/highlights schema + UI.
- Archive (items roll off the deck after N days).

**Disposition.** "+ NEW DECK" buttons should be hidden or wired to a
"coming soon" sheet until Phase 2 — current broken state sets bad
expectations. Archive can stay as a placeholder if labeled honestly.

## Brief ("Briefing" tab) — the orb commands

**Vision** (from PRODUCT_SPEC Phase 4). A short audio briefing generated
overnight from your ★ 4+ items, threaded into a coherent ~5-minute
listen. Lands at 06:30. The orb is the thing you tap to play.

**Today.**
- `[?]` Top bar: current time + state label (WAITING / READY).
- `[?]` "YOUR BRIEFING · N MIN" header with copy that changes based on
  whether you've sparked anything.
- `[?]` BriefingOrb (large) as the visual centerpiece.
- `[?]` Thread card lists up to 4 sparked items.
- `[broken]` **"TAP TO SCRY"** label under the orb — no gesture handler;
  the orb does nothing.
- `[stub]` **No audio briefing generation** (Phase 4).
- `[stub]` **No briefing script** — the threading copy is aspirational.
- `[stub]` **Sparked items via `listStarred(limit: 6)`** — not scoped to
  "today" (no time filter); shows all-time recent sparks.

**Gaps.**
- The script generator (Claude prompt that threads sparks into a 5-min
  narrative).
- TTS to audio file, stored where the app can stream it.
- Playback UI (controls, scrubber, transcript).
- Notification at 06:30 when ready.

**Disposition.** This is the most aspirational tab. Question for triage:
does it stay a tab, or collapse into Tomorrow until Phase 4? At minimum,
either wire the orb tap to *something* (even just a "Briefing not ready"
sheet) or remove the "TAP TO SCRY" call-to-action.

## Me ("Profile" tab) — the long record

**Vision** (from PRODUCT_SPEC Phase 2). The longitudinal view. 12-week
activity grid (GitHub-style) + milestone progress bars + member-since
date. Builds the sense that the daily ritual accumulates into something.

**Today.**
- `[?]` 12-week activity grid (7×12 cells, density 0–4).
- `[?]` Streak ribbon (bleeds to edges).
- `[?]` Density legend; today's cell is boxed.
- `[?]` Milestones block: 30-day streak, 1,000 cleared, 50 sparked,
  topics rated 4+.
- `[?]` Settings nav (gear icon top-right).
- `[bug]` **"MEMBER SINCE · JAN 2026"** hardcoded — not from account
  creation date.
- `[bug]` **"MAR 1" axis label** hardcoded — drifts as time passes.
- `[bug]` **Milestone math is loose** — "30-day morning streak" is
  `totalCleared / 14`, not a real streak; "Topics rated 4+" uses
  save count, not distinct topic count.
- `[stub]` **Grid uses saves+sparks as proxy** for daily cleared count,
  since `daily_session` aggregates don't exist yet.

**Gaps.**
- `daily_session` schema (per-day clear count, streak state).
- Real "member since" from `auth.users.created_at`.
- Real distinct-topic counter for the "Topics rated 4+" milestone.

**Disposition.** Hardcoded date labels are quick fixes. Milestone math
honesty is a bigger ask — needs the underlying schema. Until then,
either fix the math against existing data or relabel the milestones to
match what they actually measure.

## Article detail (modal from any list)

**Vision.** The reading surface for a single article. Topic chip + title
+ parsed headline + markdown body + action row (Skip / Spark / Save) +
"Open original" CTA. Tap Spark → opens RatingSheet.

**Today.**
- `[?]` Topic chip + prefix tag (parsed from summary).
- `[?]` Display title in italic display font; headline below.
- `[?]` Markdown body via MarkdownUI 2.4 (`.markdownTheme(.basic)`).
- `[?]` Action row with toggle states (tap again to clear).
- `[?]` Spark button → RatingSheet (same as Today).
- `[?]` "Open original" CTA (cobalt with glow shadow).

**Gaps.** None major — this surface is mostly complete.

**Disposition.** Watch for typography/spacing inconsistencies vs Today
once we triage the design system.

## Rating system

**Vision** (from PRODUCT_SPEC §3). One-tap quick rate but expressive when
the user wants depth. 5 sparks + reasons taxonomy + optional note.
Ratings train tomorrow's deck (re-rank) and drive the briefing thread.

**Today.**
- `[?]` 5-spark rating with phrase per level (skip / meh / decent /
  worth it / essential).
- `[?]` Reasons taxonomy: 9 chips (SHARP, SURPRISED ME, AGREE, DISAGREE,
  REREAD, BORING, TOO SHALLOW, JUNK, NEW TOPIC).
- `[?]` Optional note via TextEditor.
- `[?]` "+ TOMORROW" CTA (bumps to 4★) and "NEXT CARD →" CTA.
- `[stub]` **Reasons + note are NOT persisted server-side** — captured
  in the sheet but go nowhere on submit.
- `[stub]` **Spark→action mapping is a projection** — 1-2 = pass, 3 =
  star, 4+ = star + save. Temporary until real ratings table ships.

**Gaps.**
- `article_ratings` schema (sparks, reasons[], note, rated_at, article_id,
  user_id).
- Re-rank logic that consumes ratings.
- Aggregation surface (Profile / Settings: "your top rated sources").

**Disposition.** This is load-bearing: without persisted ratings, the
Briefing thread and tomorrow's re-rank are both impossible. **Priority:
ship the ratings schema next.** Once persisted, the RatingSheet becomes
honest.

## Settings

**Vision.** Toggles for things the user actually controls. Grouped by
surface (deck / briefing / rating / account).

**Today.**
- `[?]` Custom cobalt toggle style with glow.
- `[?]` Sign out (with confirmation dialog).
- `[bug]` **"Show live ticker"** toggle persists but TickerBar is always
  rendered; setting isn't read.
- `[bug]` **"Default to DECK"** toggle persists but TodayView always
  starts in `.deck`; setting isn't read.
- `[stub]` Most other toggles ("Hide read items", "Daily audio briefing",
  "Notify when ready", "Skip already-rated", "Prompt to rate on read",
  "Use ratings to re-rank") persist via `@AppStorage` but aren't wired
  to behavior.
- `[stub]` **No account deletion** (required for App Store —
  Guideline 5.1.1(v)).

**Gaps.**
- Wire the two `[bug]` toggles to actual behavior (fast).
- Account deletion flow (blocking public App Store, not TestFlight).
- Decide which `[stub]` toggles to keep visible vs hide until wired.

**Disposition.** Quick wins: wire ticker + default-mode toggles. Bigger
question: settings UI promises behaviors that don't exist — either ship
the behaviors or hide the toggles. Account deletion is App Store
submission blocker, not TestFlight blocker.

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
- `[?]` Components: TopicChip, OrbView, BriefingOrb, SparkStars,
  StatusPill, DeckCard, ListRowCard, PageMasthead, TickerBar,
  StreakRibbon, ModeToggle.

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
