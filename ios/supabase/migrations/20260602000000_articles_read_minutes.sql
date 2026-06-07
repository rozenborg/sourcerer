-- Add a read/listen time estimate captured at pull time.
--
-- Background: the iOS deck shows "1m" for everything because read time
-- was being computed from `summary.split.count / 220wpm`. Summaries
-- cluster in a tight range regardless of original length, so a 5000-word
-- article and a 300-word post both read as "1m". The fix is to compute
-- from the ORIGINAL text (or audio duration for podcasts/YouTube) at
-- pull time, then store it.
--
-- Source of truth by source_type:
--   rss / sitemap        — words(extracted text) / 220
--   scholarly*           — fixed 12 (we summarize abstracts, but the user
--                          reads the full paper, which we don't have)
--   podcast              — itunes:duration parsed from the RSS entry
--   youtube              — duration from yt-dlp metadata
--
-- Nullable: historical rows ingested before this column existed remain
-- NULL. iOS falls back to a per-kind default for NULL rows. pass 3 of
-- resummarize_pending.py drains the backlog for text sources (re-extracts
-- text via trafilatura and computes). Podcast/YouTube historical rows
-- stay NULL — backfilling them would mean re-fetching audio/captions,
-- which isn't worth it.
--
-- Postgres view gotcha (see CLAUDE.md): adding columns does NOT propagate
-- to views with `select a.*` — the view's column list was snapshotted at
-- CREATE TIME. feed_articles is dropped and recreated to expose the new
-- column.

alter table articles
  add column if not exists read_minutes int;

-- All scholarly fetchers (scholarly, scholarly_rss, scholarly_authors)
-- write `source_type = 'scholarly'` regardless of which fetcher produced
-- the row, so a single filter covers all three.
update articles
   set read_minutes = 12
 where read_minutes is null
   and source_type = 'scholarly';

-- Recreate feed_articles so iOS sees read_minutes via Article decoding.
drop view if exists feed_articles;
create view feed_articles
  with (security_invoker = true)
  as
select a.*
from articles a
where a.summary is not null
  and not exists (
    select 1 from article_interactions ai
    where ai.article_id = a.id and ai.user_id = auth.uid()
  );
