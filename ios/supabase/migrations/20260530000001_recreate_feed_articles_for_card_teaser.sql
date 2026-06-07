-- Recreate feed_articles so it exposes the new card_teaser / card_teaser_model
-- columns added in 20260530000000_articles_card_teaser.sql.
--
-- Postgres gotcha: `SELECT a.*` in a CREATE VIEW is expanded to the
-- underlying table's column list AT VIEW CREATION TIME, not at query
-- time. Adding a column to `articles` after the view exists does not
-- propagate. The view must be dropped and recreated.
--
-- The view body is identical to the May 28 definition — only the
-- column set changes (because `articles.*` now includes card_teaser).

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
