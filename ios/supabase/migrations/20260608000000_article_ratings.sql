-- Per-user article ratings — the considered signal, captured from the
-- detail view (NOT a deck swipe).
--
-- Design intent (app refocus): rating is a research dataset first, a tuning
-- input second. We capture stars + an open-form note now; we do NOT yet
-- consume it for re-ranking. That's deliberate — the goal is honest capture
-- of what the user actually thinks, in their own words.
--
-- The `reasons` column is RESERVED for a future "unlock": once a user has
-- written enough substantive notes, we analyze them to surface their own
-- recurring themes and offer those back as quick-tap reason chips. Until
-- that lands, reasons stays empty. We pre-create the column so the dataset
-- is shaped for that analysis from day one.
--
-- One row per (user, article); re-rating upserts.

create table if not exists article_ratings (
  user_id    uuid   not null references auth.users(id) on delete cascade,
  article_id bigint not null references articles(id)  on delete cascade,
  stars      int    not null check (stars between 1 and 5),
  note       text,
  reasons    text[] not null default '{}',  -- reserved; see header
  rated_at   timestamptz not null default now(),
  primary key (user_id, article_id)
);

create index if not exists article_ratings_user_idx
  on article_ratings (user_id, rated_at desc);

-- RLS: a user can only see and write their own ratings.
alter table article_ratings enable row level security;
drop policy if exists ar_select_own on article_ratings;
drop policy if exists ar_insert_own on article_ratings;
drop policy if exists ar_update_own on article_ratings;
drop policy if exists ar_delete_own on article_ratings;
create policy ar_select_own on article_ratings for select using (auth.uid() = user_id);
create policy ar_insert_own on article_ratings for insert with check (auth.uid() = user_id);
create policy ar_update_own on article_ratings for update using (auth.uid() = user_id);
create policy ar_delete_own on article_ratings for delete using (auth.uid() = user_id);
