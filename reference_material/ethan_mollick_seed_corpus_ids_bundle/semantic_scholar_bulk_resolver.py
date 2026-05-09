#!/usr/bin/env python3
"""
Resolve/refresh Semantic Scholar IDs for Ethan Mollick-style seed corpus.

Usage:
  export S2_API_KEY="..."   # optional but recommended for rate limits
  python semantic_scholar_bulk_resolver.py \
      --input ethan_mollick_seed_corpus_with_canonical_ids.csv \
      --output ethan_mollick_seed_corpus_resolved.csv

What it does:
  1. Uses existing s2_api_lookup_key values where available.
  2. Falls back to title search for unresolved exact-title rows.
  3. Accepts high-similarity title matches only; otherwise leaves rows for manual review.
  4. Does not force-match AMBIGUOUS_OR_CATEGORY rows.
"""
from __future__ import annotations

import argparse, csv, json, os, time
from difflib import SequenceMatcher
from urllib.parse import quote
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError

FIELDS = "paperId,corpusId,title,year,authors,externalIds,url,venue,publicationVenue"
API = "https://api.semanticscholar.org/graph/v1"


def request_json(url: str, api_key: str | None, sleep_s: float) -> dict:
    headers = {"User-Agent": "mollick-seed-resolver/1.0"}
    if api_key:
        headers["x-api-key"] = api_key
    req = Request(url, headers=headers)
    time.sleep(sleep_s)
    with urlopen(req, timeout=30) as resp:
        return json.loads(resp.read().decode("utf-8"))


def get_paper(key: str, api_key: str | None, sleep_s: float) -> dict | None:
    try:
        return request_json(f"{API}/paper/{quote(key, safe=':./')}?fields={FIELDS}", api_key, sleep_s)
    except HTTPError as e:
        if e.code in (404, 400):
            return None
        raise
    except URLError:
        return None


def search_title(title: str, api_key: str | None, sleep_s: float, limit: int = 5) -> list[dict]:
    data = request_json(f"{API}/paper/search?query={quote(title)}&limit={limit}&fields={FIELDS}", api_key, sleep_s)
    return data.get("data", [])


def norm(s: str) -> str:
    return " ".join("".join(ch.lower() if ch.isalnum() else " " for ch in s).split())


def title_similarity(a: str, b: str) -> float:
    return SequenceMatcher(None, norm(a), norm(b)).ratio()


def external_lookup_candidates(row: dict) -> list[str]:
    cands = []
    for prefix, col in [("CorpusID:", "semantic_scholar_corpus_id"), ("DOI:", "doi"), ("ARXIV:", "arxiv_id"), ("PMID:", "pubmed_id"), ("PMCID:", "pmcid")]:
        val = (row.get(col) or "").strip()
        if val:
            cands.append(prefix + val)
    if row.get("semantic_scholar_paper_id"):
        cands.append(row["semantic_scholar_paper_id"].strip())
    if row.get("s2_api_lookup_key"):
        cands.insert(0, row["s2_api_lookup_key"].strip())
    # de-dupe preserving order
    seen, out = set(), []
    for c in cands:
        if c and c not in seen:
            out.append(c); seen.add(c)
    return out


def update_from_paper(row: dict, paper: dict, source: str, score: float | None = None) -> dict:
    row["semantic_scholar_paper_id"] = paper.get("paperId") or row.get("semantic_scholar_paper_id", "")
    row["semantic_scholar_corpus_id"] = str(paper.get("corpusId") or row.get("semantic_scholar_corpus_id", ""))
    row["semantic_scholar_url"] = paper.get("url") or (f"https://www.semanticscholar.org/paper/{row['semantic_scholar_paper_id']}" if row.get("semantic_scholar_paper_id") else "")
    row["canonical_title"] = paper.get("title") or row.get("canonical_title") or row.get("original_title")
    ext = paper.get("externalIds") or {}
    row["doi"] = ext.get("DOI") or row.get("doi", "")
    row["arxiv_id"] = ext.get("ArXiv") or row.get("arxiv_id", "")
    row["pubmed_id"] = ext.get("PubMed") or row.get("pubmed_id", "")
    row["pmcid"] = ext.get("PubMedCentral") or row.get("pmcid", "")
    row["s2_api_lookup_key"] = "CorpusID:" + row["semantic_scholar_corpus_id"] if row.get("semantic_scholar_corpus_id") else "S2PaperID:" + row.get("semantic_scholar_paper_id", "")
    row["status"] = "S2_RESOLVED"
    row["confidence"] = "HIGH" if source != "title_search" or (score is not None and score >= 0.94) else "MEDIUM"
    detail = f"Resolved by {source}"
    if score is not None:
        detail += f"; title_similarity={score:.3f}"
    row["resolver_notes"] = detail
    return row


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--input", required=True)
    ap.add_argument("--output", required=True)
    ap.add_argument("--sleep", type=float, default=1.1, help="Seconds between API calls; reduce if using an API key and allowed by your quota.")
    ap.add_argument("--min-title-score", type=float, default=0.92)
    args = ap.parse_args()
    api_key = os.environ.get("S2_API_KEY")

    with open(args.input, newline="", encoding="utf-8") as f:
        rows = list(csv.DictReader(f))
        fieldnames = f.fieldnames or []

    for row in rows:
        status = row.get("status", "")
        if status == "AMBIGUOUS_OR_CATEGORY":
            continue
        if status == "DUPLICATE_OR_VARIANT":
            continue
        if row.get("semantic_scholar_paper_id") and row.get("semantic_scholar_corpus_id"):
            continue

        resolved = None
        for key in external_lookup_candidates(row):
            if key.startswith("S2PaperID:"):
                key = key.split(":", 1)[1]
            if key.startswith("SSRN:"):
                continue
            paper = get_paper(key, api_key, args.sleep)
            if paper and paper.get("paperId"):
                resolved = update_from_paper(row, paper, f"lookup:{key}")
                break
        if resolved:
            continue

        title = row.get("canonical_title") or row.get("original_title")
        if not title:
            continue
        try:
            candidates = search_title(title, api_key, args.sleep)
        except Exception as e:
            row["resolver_notes"] = f"Title search failed: {e}"
            continue
        if not candidates:
            row["resolver_notes"] = "No Semantic Scholar title-search candidates returned."
            continue
        scored = [(title_similarity(title, c.get("title", "")), c) for c in candidates]
        scored.sort(reverse=True, key=lambda x: x[0])
        score, best = scored[0]
        if score >= args.min_title_score:
            update_from_paper(row, best, "title_search", score)
        else:
            row["resolver_notes"] = f"Manual review required; best title similarity {score:.3f}: {best.get('title')}"

    # Second pass: re-inherit duplicate IDs from their canonical row, if applicable.
    by_id = {r.get("row_id"): r for r in rows}
    id_fields = ["canonical_title","semantic_scholar_paper_id","semantic_scholar_corpus_id","semantic_scholar_url","doi","arxiv_id","pubmed_id","pmcid","s2_api_lookup_key"]
    for row in rows:
        dup = row.get("duplicate_of_row")
        if dup and dup in by_id:
            base = by_id[dup]
            for f in id_fields:
                row[f] = base.get(f, row.get(f, ""))
            row["status"] = "DUPLICATE_OR_VARIANT"
            row["confidence"] = base.get("confidence", row.get("confidence", ""))

    with open(args.output, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader(); writer.writerows(rows)

if __name__ == "__main__":
    main()
