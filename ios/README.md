# Sourcerer iOS

Native SwiftUI client for the Sourcerer content database. Reads from the same
Supabase project the Python pipeline writes to; adds per-user pass / star /
save and (later) decks on top.

> **Status:** lives inside the `sourcerer` repo while we get it to a working
> state, then gets extracted into its own `sourcerer-ios` repo (see
> _Extraction_ below).

## Prerequisites

1. **Mac** with **Xcode 16+** (free, App Store).
2. **Apple Developer Program** ($99/yr) — required for Sign in with Apple.
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
- For Apple, follow Supabase's Apple-OAuth guide to create a Services ID + key
  in the Apple Developer portal. Redirect URL is
  `https://<project-ref>.supabase.co/auth/v1/callback`.

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
