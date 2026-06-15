-- Move ratings from a 1-5 star scale to a three-level thumbs verdict, captured
-- on the deck card with an optional comment.
--
-- Design intent (app refocus): the verdict is the quick signal; the comment is
-- the real payload — open-form feedback we collect to personalize the feed over
-- time. We keep the original `stars` column (nullable now) so any pre-thumbs
-- ratings survive; new ratings write `verdict` + `note` and leave `stars` null.
--
--   verdict: 'down' (not for me) | 'up' (worth it) | 'up_up' (loved it)
--   note:    the open-form comment (reused from the stars-era column)

alter table article_ratings
  add column if not exists verdict text
    check (verdict in ('down', 'up', 'up_up'));

-- stars was NOT NULL with a 1-5 check; verdict-only ratings need it nullable.
-- The CHECK (stars between 1 and 5) passes for NULL, so it can stay as-is.
alter table article_ratings
  alter column stars drop not null;
