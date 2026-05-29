-- Hide articles whose summary hasn't been generated yet from the feed.
--
-- Background: pull.py now uses Gemini Flash for summarization, with a
-- fallback to Sonnet via resummarize_pending.py (a separate 09:00 UTC
-- cron). When Gemini is briefly unavailable, articles can land in the
-- table with summary = NULL until the re-summarize cron resolves them
-- (typically within an hour). The deck shouldn't show those — a card
-- with no body text is broken UX. Once the summary populates, the
-- article appears in the feed automatically.

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
