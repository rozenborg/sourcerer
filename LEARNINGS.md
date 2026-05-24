# Learnings

Running log of things we figured out the hard way — tool quirks, setup gotchas, debug wins. The goal is to save tokens and time next time the same obstacle shows up.

**Format.** Newest entries on top. Group under a section if one fits; create a new section liberally. Each entry: a one-line title, then 1–3 lines covering *what we hit*, *what fixed it*, and (if non-obvious) *why*. Date in parens.

**What belongs here.** Specific obstacles overcome, tool/version quirks, working incantations, surprising failure modes. NOT general best practices, NOT things already documented in `CLAUDE.md` or `README.md`.

**Pruning.** When an entry becomes permanent project truth, graduate it to `CLAUDE.md` and delete it from here. When an entry is superseded (tool fixed, approach abandoned), delete it. Keep this file under ~150 lines.

---

## iOS simulator

- **Launch-arg–driven debug preview** (2026-05-24) — to inspect new SwiftUI screens before auth is wired, gate state on `ProcessInfo.processInfo.arguments` inside `#if DEBUG`. Pass via `xcrun simctl launch <device> <bundle-id> --preview --tab=N`. Strips cleanly in Release. Works even on tabbed `TabView` if you bind `@State var selection` to a tag and seed from the args.

- **`xcrun simctl io <device> screenshot path.png` for snapshot loops** (2026-05-24) — beats opening the Simulator GUI for each tab. Combine with `xcrun simctl terminate` + relaunch with different launch args to capture every screen state. Default iPhone 16 names are gone — `xcrun simctl list devices` to find the current name (in iOS 26.x it's "iPhone 17 Pro").

## Design system port

- **MarkdownUI's `markdownTextStyle` API moved** (2026-05-24) — the `FontFamily(.system()) / FontSize(...) / ForegroundColor(...)` builders that older docs reference don't exist in 2.4. Use `.markdownTheme(.basic)` and let it inherit; customize via `.markdownTheme()` if more control is needed.<!--
Example entry shape (delete once we have real ones):

## YouTube ingest

- **`web` player_client returns empty subtitle dicts in CI** (2026-05-24) — pin `player_client=android` in yt-dlp opts. `youtube-transcript-api` is also IP-blocked from datacenter ranges, so fetching json3 directly via httpx is the path that works on GitHub Actions runners.
-->
