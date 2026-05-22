# Sourcerer iOS

Native SwiftUI client for the Sourcerer content database. Reads from the same
Supabase project the Python pipeline writes to; adds per-user pass / star /
save and (later) decks on top.

> **Status:** lives inside the `sourcerer` repo while we get it to a working
> state, then gets extracted into its own `sourcerer-ios` repo (see
> _Extraction_ below).

## Prerequisites

1. **Mac** with **Xcode 16+** (free, App Store).
2. **Apple Developer Program** membership — required for Sign in with Apple,
   TestFlight, and App Store submission. Team ID `68J52LPHNX` is wired into
   `project.yml`.
3. [**xcodegen**](https://github.com/yonaskolb/XcodeGen) — generates the
   `.xcodeproj` from `project.yml`. `brew install xcodegen`.
4. [**Supabase CLI**](https://supabase.com/docs/guides/cli) — applies
   migrations. `brew install supabase/tap/supabase`.

## One-time setup

```bash
cd ios

# 1. Generate the Xcode project from project.yml
xcodegen

# 2. Configure secrets
cp SourcererApp/Resources/Secrets.plist.example SourcererApp/Resources/Secrets.plist
# Edit Secrets.plist and fill in:
#   SUPABASE_URL       https://<project-ref>.supabase.co
#   SUPABASE_ANON_KEY  (Supabase dashboard > Project Settings > API > anon public)

# 3. Apply migrations against the live Supabase project
supabase link --project-ref <your-project-ref>
supabase db push
# Or paste each .sql file from supabase/migrations/ into the SQL editor.

# 4. Open and run
open SourcererApp.xcodeproj
```

In Xcode, on first build:
- Select your team under **Signing & Capabilities**.
- Confirm **Sign in with Apple** capability is present (xcodegen adds it via
  the entitlements file, but Apple needs your team to enable it).
- Plug in an iPhone (or use the iOS 17+ simulator for everything except Apple
  sign-in itself).

In the **Supabase dashboard**:
- **Authentication > Providers**: enable **Email** and **Apple**.
- For Apple, the app uses **native** Sign in with Apple (the
  `SignInWithAppleButton` → `signInWithIdToken` flow in `AuthView.swift`).
  Native flow only needs the App ID with the Sign in with Apple capability —
  no Services ID required. Configure the Apple provider in Supabase by
  setting the **Client IDs** field to your bundle id
  (`com.rozenborg.sourcerer`); leave the Services ID + secret key empty
  unless you later add a web/Android client. The redirect URL
  `https://<project-ref>.supabase.co/auth/v1/callback` is only used by the
  web OAuth flow we don't trigger.

## Layout

```
ios/
├── project.yml                    # xcodegen config
├── supabase/migrations/           # iOS-owned DDL (interactions, decks, RLS)
└── SourcererApp/
    ├── SourcererApp.swift          # @main entry + RootTabView
    ├── AppEnvironment.swift        # DI container
    ├── SourcererApp.entitlements   # Sign in with Apple
    ├── Models/                     # Article, ArticleInteraction, Deck, ...
    ├── Services/                   # AuthService, repositories, parser
    ├── Views/
    │   ├── Auth/                   # Sign-in screen
    │   ├── Feed/                   # FeedView + ArticleCard
    │   ├── Detail/                 # ArticleDetailView
    │   ├── Library/                # StarredView, SavedView
    │   └── Shared/                 # SourceBadge, preview helpers
    └── Resources/
        ├── Secrets.plist.example   # checked in
        ├── Secrets.plist           # gitignored, you create this
        └── Assets.xcassets/
```

## Migrations

Two SQL files in `supabase/migrations/`:

1. `…_articles_image_url_and_rls.sql` — adds `articles.image_url` and enables
   RLS with a read-all `select` policy. The pipeline keeps writing via the
   service key, which bypasses RLS.
2. `…_interactions_decks.sql` — creates `article_interactions`,
   `decks`, `deck_items`, plus per-user RLS policies.

Apply them in numeric order. Re-runs are safe (`if not exists`, `drop policy
if exists`).

## Development loop

Every top-level view has a `#Preview` block backed by `MockData.articles`
and `AppEnvironment.preview()` (both in
`SourcererApp/Views/Shared/PreviewSupport.swift`). Open any view file in
Xcode and the preview canvas renders instantly without launching the app.
Best for component-level work (typography, spacing, individual state
variants).

To preview an alternate state, instantiate a custom
`PreviewArticleRepository`:

```swift
#Preview("Empty") {
    let env = AppEnvironment.preview(articles: PreviewArticleRepository(starred: []))
    return StarredView().environment(env).environment(env.auth)
}
```

For full-app changes that need real Supabase data, just do a normal
Cmd+R rebuild from Xcode.

## Tests

Unit tests live in `SourcererAppTests/` and use [Swift Testing](https://developer.apple.com/xcode/swift-testing/)
(Xcode 16+). Run from Xcode with `Cmd+U`, or from the command line:

```bash
cd ios
xcodebuild test \
  -project SourcererApp.xcodeproj \
  -scheme SourcererApp \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

Replace `iPhone 17` with any installed simulator — `xcrun simctl list devices available`
shows what you have. Xcode bundles a fresh set of simulators with each
release, so the device name will drift over time.

`AppEnvironment` accepts injected `(supabaseURL:, supabaseAnonKey:)` for
tests/previews, with a no-arg `init()` that falls back to `Secrets.plist`
for the live app.

## Phase 1 scope (this commit)

- Apple + email auth.
- FeedView (unseen articles, keyset paginated by `fetched_at`).
- ArticleDetailView with markdown summary + pass/star/save buttons.
- StarredView, SavedView.

## Coming next

- **Phase 2** — TriageView (swipe-card stack, pass/star/save by gesture),
  per-source-type styling polish, search.
- **Phase 3** — Decks (DecksView, DeckDetailView, "Add to deck" sheet),
  notes/highlights via `article_interactions.meta`.

## Extraction (when ready)

This folder will move out into a standalone `rozenborg/sourcerer-ios` repo.

```bash
# In sourcerer (preserving file-level history):
git subtree split --prefix=ios -b ios-only

# Create empty rozenborg/sourcerer-ios on GitHub, then locally:
git clone git@github.com:rozenborg/sourcerer-ios.git
cd sourcerer-ios
git pull /absolute/path/to/sourcerer ios-only
git push -u origin main

# Back in sourcerer, in a follow-up PR:
git rm -r ios/
# Update sourcerer/README.md with a link to the new repo.
```
