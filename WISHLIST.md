# Wishlist

Ideas for Sourcerer, kept loose. Check off when implemented.

## Easier source onboarding

The dream: paste a name or URL, get a working entry in `feeds.yaml`. Build in layers:

**Layer 1: New source types** (concrete, scoped)
- [x] `youtube` fetcher — yt-dlp for both listing and caption-URL discovery (android player_client). Captions fetched as json3 via httpx. youtube-transcript-api was tried first but is IP-blocked from datacenter ranges; videos.xml is similarly blocked.
- [ ] Whisper fallback for YouTube videos with captions disabled (yt-dlp can already grab the audio)
- [ ] Podcast transcript routing — many podcasts publish transcripts in shownotes; check before downloading audio

**Layer 2: URL-based add flow** (`add_source.py`)
- [x] Probe a URL and auto-detect type
  - [x] RSS auto-discovery via `<link rel="alternate" type="application/rss+xml">`
  - [x] Common-path fallbacks: `/feed`, `/rss`, `/atom`, `/feed.xml`
  - [x] Detect podcast vs article feed via `<enclosure type="audio/...">`
  - [x] Detect YouTube channel/handle URLs → wire as `youtube` type with `channel_url`
  - [x] Auto-wrap Substack hosts with `substack-proxy.workers.dev` (always, since CI is CF-blocked)
  - [x] Apple Podcasts URL → resolve via iTunes Search API
  - [ ] Sitemap fallback: pull from `robots.txt`, ask Claude to suggest a `url_pattern` from a URL sample
- [x] Lightweight preview before appending — shows latest entry title + count without burning Claude/Whisper budget
- [ ] Auto-decide whether a feed needs a `keywords` filter (default off; prompt if it looks general-interest)

**Layer 3: Name-based discovery** (wraps Layer 2)
- [ ] Resolve "the sequoia capital youtube channel" → candidate feeds across YouTube/iTunes/web
- [ ] Multi-surface entities (e.g. Sequoia has YouTube + 2 podcasts + a blog) — present top matches with one-line previews, user picks which surfaces to subscribe to

## Source discovery

The dream: find new high-signal sources automatically, not mediocre ones.

- [ ] Mine citations from existing sources — proper nouns + URLs in summaries/transcripts → cluster → propose top N candidates with provenance ("mentioned 3x by sources you trust this month")
- [ ] Capture a taste signal (kept-reading vs skipped, or a thumbs-up/down) so ranking has ground truth
- [ ] Once taste signal exists: rank candidates by predicted relevance, not just frequency

## Scholarly papers (Mollick-style filter)

Four sources running: Semantic Scholar recommender (seeded from the JSONL bundle), NBER feed, arXiv (cs.HC + cs.CY), and full author watchlist. All except the watchlist run through the Mollick-likeness rubric.

- [x] Add NBER as a second source (RSS-based, scored)
- [x] Add arXiv (cs.HC + cs.CY) as a third source
- [ ] ~~Add SSRN as a source~~ — **dead end**: Elsevier deprecated public eJournal RSS after acquiring SSRN; site is anti-bot. HBS/Wharton/NYU Stern/law-school working papers SSRN hosts are unreachable without scraping or paid access. Workaround now in place: the watchlist source pulls papers by named authors directly from S2.
- [x] Look up canonical DOIs/arXiv IDs for unresolved seeds (delivered via JSONL bundle in `reference_material/`)
- [x] Cache resolved S2 paperIds (effectively done — bundle pre-resolves them, no title-search calls at runtime)
- [x] Apply the §8 author watchlist (`scholarly_authors` fetcher — watchlist authors bypass scoring entirely)
- [ ] **Pin authorIds in feeds.yaml for collision-prone names.** First run surfaced a false-positive: "Sida Peng" matched a computer-vision researcher's Gaussian-splatting papers instead of the Microsoft developer-productivity Sida Peng. Fix is one-time per affected name: replace the string with the right S2 authorId.
- [ ] Auto-discover new seed papers — when Mollick himself cites/posts about a paper that scores well, auto-add to seeds
- [ ] Add JAMA / NEJM AI / Nature Medicine RSS (medical decision-support evidence is high signal for human-AI judgment)
- [ ] Add the §11 hype penalty to the scoring rubric — deduct 0-3 for benchmark-only / no human baseline / vendor marketing / overclaiming
- [ ] Resolve the 34 UNRESOLVED_LOOKUP_REQUIRED rows in the bundle (run the included `semantic_scholar_bulk_resolver.py` against the JSONL and merge results)

## YouTube cookie management

- [ ] **Refresh `YOUTUBE_COOKIES` secret regularly OR move to self-hosted runner.** First successful run in mid-May; cookies have re-expired multiple times since. Datacenter-IP access patterns burn through the session quickly. Options: weekly cron from a local machine that pushes fresh cookies via `gh secret set`, or self-hosted GitHub Actions runner on a residential-IP machine (kills the problem entirely).

## iOS app

Native SwiftUI client in `ios/`. Phase 1 scope (Apple + email auth, FeedView, ArticleDetailView, StarredView, SavedView) is shipped. Next phases scoped in [ios/README.md](ios/README.md#coming-next). The app lives in this repo until stable, then extracts to `rozenborg/sourcerer-ios`.

**Phase 2 — Triage + polish**
- [ ] TriageView — swipe-card stack with pass/star/save by gesture
- [ ] Per-source-type styling polish (RSS vs podcast vs YouTube vs scholarly render differently)
- [ ] Search across articles

**Phase 3 — Decks**
- [ ] DecksView, DeckDetailView, "Add to deck" sheet
- [ ] Notes/highlights via `article_interactions.meta`

**Submission readiness** (not blocking TestFlight, blocking public App Store)
- [ ] Account Deletion flow — required by Apple Guideline 5.1.1(v); auth currently only supports sign-out
- [ ] App Store listing assets: screenshots, app description, privacy policy URL, support URL, age rating

**Extraction**
- [ ] Move `ios/` to standalone `rozenborg/sourcerer-ios` repo via `git subtree split --prefix=ios` (procedure documented in [ios/README.md](ios/README.md#extraction-when-ready)). Trigger: app is stable enough that pipeline and client cadences want to diverge.

## Other ideas

(Add as they come up.)

---

## Done

- 2026-05-06 — `youtube` fetcher with caption-preferred routing
- 2026-05-06 — `add_source.py` URL-based add flow (RSS, Apple Podcasts, YouTube, Substack, HTML-with-feed)
- 2026-05-07 — `scholarly` fetcher with Mollick-style filter (Semantic Scholar recommender + Claude-scored 0-20 rubric, threshold 14)
- 2026-05-08 — `scholarly_rss` fetcher (RSS feeds with same Mollick-likeness scoring); wired NBER + arXiv (cs.HC, cs.CY) as scholarly sources
- 2026-05-08 — `scholarly_authors` fetcher (full coverage of named researchers via S2 author/papers endpoint, no scoring filter); wired ~30-name §8 watchlist
- 2026-05-09 — Wired scholarly fetcher to the canonical-IDs JSONL bundle in `reference_material/` — went from 11 working seeds (rate-limit luck) to 99 verified seeds with zero title-search API calls at runtime. Verified end-to-end: workflow run produced 30 new articles (15 from recommender, 14 from watchlist, plus 1 from existing sources).
- 2026-05-10 — Scaffolded SwiftUI iOS app under `ios/` (Phase 1 scope: Apple + email auth, FeedView with keyset pagination, ArticleDetailView, StarredView, SavedView).
- 2026-05-20 — iOS app running on physical device end-to-end against live Supabase.
- 2026-05-21 — Activated paid Apple Developer team (`68J52LPHNX`); fixed submission blockers.
- 2026-05-22 — Sign-out button, Swift Testing target with `ParsedSummary` unit tests, Privacy Manifest (`PrivacyInfo.xcprivacy`), and TestFlight runbook. Hot-reload via Inject was tried and removed.
- 2026-05-22 — Orb app icon (refreshed 2026-05-24 to opaque variant).
