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

## Other ideas

(Add as they come up.)

---

## Done

- 2026-05-06 — `youtube` fetcher with caption-preferred routing
- 2026-05-06 — `add_source.py` URL-based add flow (RSS, Apple Podcasts, YouTube, Substack, HTML-with-feed)
