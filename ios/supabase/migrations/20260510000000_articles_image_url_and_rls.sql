-- Sourcerer iOS migration 1/2: extend articles + enable RLS for read-all.
--
-- This file lives in the iOS repo (Option A: currently inside sourcerer/ios/,
-- will move with the subtree at extraction time) but it touches a table owned
-- by the Python pipeline. Apply BEFORE 20260510000001_interactions_decks.sql.
--
-- Apply via: supabase db push   (with linked project)
--   or:     paste into Supabase SQL editor

-- Optional UI affordance; pipeline can backfill og:images later.
alter table articles add column if not exists image_url text;

-- App reads articles for any authenticated user. Pipeline writes via service key,
-- which bypasses RLS, so this read-all policy is safe for the pipeline.
alter table articles enable row level security;

drop policy if exists articles_read_all on articles;
create policy articles_read_all on articles
  for select
  using (true);
