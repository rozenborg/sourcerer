-- Sourcerer iOS migration 2/2: per-user article interactions + decks.
--
-- One row per (user, article). Each action is a nullable timestamp,
-- so star + save can be independent OR mutex-by-UI (clear the others
-- when one is set). The data model doesn't force a UX choice.

create table if not exists article_interactions (
  user_id    uuid   not null references auth.users(id) on delete cascade,
  article_id bigint not null references articles(id)  on delete cascade,
  passed_at  timestamptz,
  starred_at timestamptz,
  saved_at   timestamptz,
  meta       jsonb  not null default '{}'::jsonb,
  primary key (user_id, article_id)
);

-- Partial indexes: only index rows that actually have the action set.
create index if not exists article_interactions_starred_idx
  on article_interactions (user_id, starred_at desc)
  where starred_at is not null;
create index if not exists article_interactions_saved_idx
  on article_interactions (user_id, saved_at desc)
  where saved_at is not null;

-- Decks: themed collections (projects, themes, questions).
create table if not exists decks (
  id          bigserial primary key,
  user_id     uuid not null references auth.users(id) on delete cascade,
  name        text not null,
  description text,
  created_at  timestamptz not null default now()
);
create index if not exists decks_user_idx on decks (user_id, created_at desc);

create table if not exists deck_items (
  deck_id    bigint not null references decks(id)    on delete cascade,
  article_id bigint not null references articles(id) on delete cascade,
  added_at   timestamptz not null default now(),
  position   int,
  note       text,
  primary key (deck_id, article_id)
);
create index if not exists deck_items_article_idx on deck_items (article_id);

-- RLS

alter table article_interactions enable row level security;
drop policy if exists ai_select_own on article_interactions;
drop policy if exists ai_insert_own on article_interactions;
drop policy if exists ai_update_own on article_interactions;
drop policy if exists ai_delete_own on article_interactions;
create policy ai_select_own on article_interactions for select using (auth.uid() = user_id);
create policy ai_insert_own on article_interactions for insert with check (auth.uid() = user_id);
create policy ai_update_own on article_interactions for update using (auth.uid() = user_id);
create policy ai_delete_own on article_interactions for delete using (auth.uid() = user_id);

alter table decks enable row level security;
drop policy if exists decks_select_own on decks;
drop policy if exists decks_insert_own on decks;
drop policy if exists decks_update_own on decks;
drop policy if exists decks_delete_own on decks;
create policy decks_select_own on decks for select using (auth.uid() = user_id);
create policy decks_insert_own on decks for insert with check (auth.uid() = user_id);
create policy decks_update_own on decks for update using (auth.uid() = user_id);
create policy decks_delete_own on decks for delete using (auth.uid() = user_id);

-- deck_items inherits ownership from its parent deck.
alter table deck_items enable row level security;
drop policy if exists deck_items_select_own on deck_items;
drop policy if exists deck_items_write_own  on deck_items;
create policy deck_items_select_own on deck_items for select
  using (exists (select 1 from decks d where d.id = deck_id and d.user_id = auth.uid()));
create policy deck_items_write_own on deck_items for all
  using (exists (select 1 from decks d where d.id = deck_id and d.user_id = auth.uid()))
  with check (exists (select 1 from decks d where d.id = deck_id and d.user_id = auth.uid()));

-- Feed view: articles the current user has not yet pass/star/saved.
-- security_invoker = true means RLS is evaluated as the calling user, so
-- auth.uid() in the where clause behaves correctly per request.
drop view if exists feed_articles;
create view feed_articles
  with (security_invoker = true)
  as
select a.*
from articles a
where not exists (
  select 1 from article_interactions ai
  where ai.article_id = a.id and ai.user_id = auth.uid()
);
