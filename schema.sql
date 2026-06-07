-- Sourcerer schema. Paste this into Supabase SQL Editor and Run.

create table if not exists articles (
  id                 bigserial primary key,
  url                text unique not null,
  title              text,
  source_id          text not null,
  source_name        text,
  source_type        text,
  published_at       timestamptz,
  fetched_at         timestamptz not null default now(),
  summary            text,
  card_teaser        text,
  card_teaser_model  text,
  raw_text           text,
  metadata           jsonb default '{}'::jsonb
);

create index if not exists articles_source_id_idx     on articles (source_id);
create index if not exists articles_published_at_idx  on articles (published_at desc);
create index if not exists articles_fetched_at_idx    on articles (fetched_at desc);
create index if not exists articles_summary_fts_idx   on articles using gin (to_tsvector('english', coalesce(summary,'') || ' ' || coalesce(title,'')));

create table if not exists source_runs (
  id          bigserial primary key,
  source_id   text not null,
  ran_at      timestamptz not null default now(),
  ok          boolean not null,
  new_count   int not null default 0,
  error       text
);

create index if not exists source_runs_source_id_idx on source_runs (source_id, ran_at desc);

-- Convenience view: latest run per source.
-- security_invoker = true runs the view as the querying user (respects
-- their RLS on source_runs) rather than as the view creator (Supabase's
-- default, which Supabase Advisor flags as "Security Definer View").
drop view if exists source_health;
create view source_health
  with (security_invoker = true)
  as
select distinct on (source_id)
  source_id,
  ran_at      as last_run_at,
  ok          as last_ok,
  error       as last_error,
  new_count   as last_new_count
from source_runs
order by source_id, ran_at desc;
