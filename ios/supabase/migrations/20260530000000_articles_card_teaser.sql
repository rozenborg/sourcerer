-- Add a short "card teaser" derived from the rich summary.
--
-- Background: pull.py writes a comprehensive Gemini Flash summary into
-- `summary`. That output is rich and variable-length — good for the iOS
-- detail view, but too long and unshaped for the deck card UI where the
-- reader has 25-45 words to decide whether to swipe past or read on.
--
-- A second cheap presentation pass (Haiku 4.5 via fetchers.present())
-- runs over the summary and writes a 1-2 sentence teaser here.
-- `card_teaser_model` records which model produced it, for auditing /
-- targeted regeneration if we ever change the prompt.
--
-- Nullable: presentation is best-effort. If Haiku fails, iOS falls back
-- to deriving a body line from `summary`. resummarize_pending.py picks
-- up NULL teasers on its 09:00 UTC cron.
--
-- The feed_articles view must be DROPPED AND RECREATED to expose these
-- new columns — see 20260530000001_recreate_feed_articles_for_card_teaser.sql.
-- Postgres expands `select a.*` to an explicit column list at view
-- creation time; adding columns to the underlying table does NOT
-- propagate to the view automatically. (Don't make the mistake the
-- earlier comment here did.)

alter table articles
  add column if not exists card_teaser       text,
  add column if not exists card_teaser_model text;
