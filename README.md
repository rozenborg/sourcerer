# Sourcerer

Headless content database. A daily job fetches articles + podcast transcripts from configured sources, summarizes them via Gemini 2.5 Flash (with a Sonnet fallback), and upserts rows into Supabase. Other apps (review UIs, MCP servers, Skills, dashboards) read from Supabase.

- **Source of truth:** Supabase (`articles` table)
- **Schedule:** GitHub Actions cron — daily pull at 08:00 UTC, NULL-summary retry at 09:00 UTC
- **Adding sources:** edit `feeds.yaml`

**Doc map**
- [SPEC.md](SPEC.md) — what Sourcerer is becoming (product spec, by capability)
- [CLAUDE.md](CLAUDE.md) — code shape + non-obvious engineering gotchas
- [ios/README.md](ios/README.md) — iOS setup, xcodegen, TestFlight runbook

## Architecture

```
feeds.yaml ──► pull.py ──► fetchers.py ──► Gemini Flash (summarize) ──► Supabase.articles
                                                ▲                              │
                                                │                              │
              resummarize_pending.py (09:00 UTC) ┴──► Sonnet fallback if needed │
                                                                                │
                                  (any consumer: app, MCP, Skill, SPA, etc.) ◄──┘
```

If Gemini is briefly unavailable during the 08:00 UTC pull, articles land in
the table with `summary = NULL`. The 09:00 UTC `resummarize_pending.py` cron
picks those up, retries Gemini, and falls back to Sonnet if Gemini is still
down. The iOS feed view hides NULL-summary rows so users don't see broken cards.

## One-time setup

### 1. Create the Supabase project

1. Go to https://supabase.com → Sign in → "New project"
2. Pick a name (e.g. `sourcerer`), set a database password (save it), choose a region.
3. Wait ~2 minutes for the project to provision.
4. In the left sidebar, open **SQL Editor** → **New query**.
5. Paste the contents of [`schema.sql`](schema.sql) → click **Run**. This creates the `articles` and `source_runs` tables plus a `source_health` view.

### 2. Get the API credentials

In the Supabase dashboard:

1. **Settings → API**.
2. Copy `Project URL` → this is `SUPABASE_URL`.
3. Copy the `service_role` key (under "Project API keys") → this is `SUPABASE_SERVICE_KEY`. **This key bypasses row-level security; never expose it client-side.** Only `pull.py` and trusted backends use it.
4. Anonymous read clients (web apps, MCP, etc.) should use the `anon` key instead.

### 3. Configure GitHub Actions

In the new GitHub repo for sourcerer:

**Settings → Secrets and variables → Actions → New repository secret** — add:

- `GEMINI_API_KEY` — primary summarization (Gemini 2.5 Flash). Get one at https://aistudio.google.com/apikey. Paid tier required for production volume — free tier caps Flash at 20 req/day.
- `ANTHROPIC_API_KEY` — Sonnet fallback used by `resummarize_pending.py` when Gemini stays unavailable
- `OPENAI_API_KEY` — Whisper transcription for podcasts
- `SUPABASE_URL`
- `SUPABASE_SERVICE_KEY`

Two workflows run on schedule:
- [`.github/workflows/daily.yaml`](.github/workflows/daily.yaml) — 08:00 UTC daily, the main ingest
- [`.github/workflows/resummarize.yaml`](.github/workflows/resummarize.yaml) — 09:00 UTC daily, picks up any `summary = NULL` rows from the morning run and retries (Gemini → Sonnet fallback)

Both can also be triggered manually via the Actions tab.

### 4. Local dev

```bash
cd sourcerer
python3.11 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

export GEMINI_API_KEY=...        # primary summarizer
export ANTHROPIC_API_KEY=...     # Sonnet fallback (used by resummarize_pending.py)
export OPENAI_API_KEY=...        # optional, only for podcasts
export SUPABASE_URL=https://xxx.supabase.co
export SUPABASE_SERVICE_KEY=...

python pull.py
# To retry articles that landed with NULL summaries:
python resummarize_pending.py
```

## Adding sources

Edit [`feeds.yaml`](feeds.yaml). Three source types are supported:

```yaml
sources:
  - id: my-rss-source            # stable identifier — used as primary key for runs
    name: "Display Name"
    type: rss                    # rss | sitemap | podcast
    feed_url: https://...        # required for rss/podcast
    keywords: [AI, LLM]          # optional — only keep entries matching these terms

  - id: my-sitemap-source
    name: "Some Blog"
    type: sitemap
    url: https://example.com/sitemap.xml
    url_pattern: "/blog/"        # optional — only crawl URLs containing this string
    keywords: [...]              # optional

  - id: my-podcast
    name: "A Podcast"
    type: podcast
    feed_url: https://...
```

Substack feeds are usually blocked from GitHub Actions IPs — route them through the existing proxy: `https://substack-proxy.rozenborg.workers.dev/?url=https://yourblog.substack.com/feed`.

## Schema

```
articles
  id            bigserial PK
  url           text UNIQUE      -- dedup key
  title         text
  source_id     text             -- matches feeds.yaml id
  source_name   text
  source_type   text             -- rss | sitemap | podcast
  published_at  timestamptz
  fetched_at    timestamptz      -- when sourcerer first saw it
  summary       text             -- Claude-generated headline + bullets
  raw_text      text             -- reserved (currently unused, kept for future re-summarization)
  metadata      jsonb            -- reserved

source_runs
  id, source_id, ran_at, ok, new_count, error

source_health  (view: latest run per source)
  source_id, last_run_at, last_ok, last_error, last_new_count
```

## Querying from other apps

Any Supabase client can read the data. Examples:

**JavaScript** (browser or Node, using the `anon` key):

```js
import { createClient } from '@supabase/supabase-js'
const sb = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

const { data } = await sb
  .from('articles')
  .select('*')
  .order('published_at', { ascending: false })
  .limit(50)
```

**Python:**

```python
from supabase import create_client
sb = create_client(SUPABASE_URL, SUPABASE_ANON_KEY)
recent = sb.table('articles').select('*').order('published_at', desc=True).limit(50).execute()
```

**Direct REST** (Supabase auto-generates this):

```
GET https://<project>.supabase.co/rest/v1/articles?order=published_at.desc&limit=50
Authorization: Bearer <anon-key>
apikey: <anon-key>
```

For public read access without an API key, enable RLS with a permissive `SELECT` policy on `articles`. By default the schema has no RLS — meaning the service key works but anon access is blocked. Decide intentionally.

## Notes

- **Dedup:** the `url` UNIQUE constraint is the real safety net. `pull.py` also pulls recent URLs per source to skip duplicates before paying for Claude.
- **No markdown files.** This repo is the engine, not an archive. If you want a markdown mirror, write a separate script that exports rows to files — but Supabase's daily backups already cover the durability case on the paid tier.
- **Health observability:** query `source_health` to see which sources are failing.
- **Cost:** Supabase + Cloudflare free tiers cover this workload comfortably. The recurring cost is Gemini API for summarization, occasional Anthropic API (fallback summaries when Gemini is briefly unavailable), and OpenAI for podcast transcription.
