---
name: kb-maintain
description: Health-check and consistency pass for the knowledge base — finds orphans, contradictions, missing links, stale pages, and uses graph analysis algorithms (Jaccard, Adamic-Adar, clustering) to predict missing connections.
---

# kb-maintain — Knowledge Base Maintenance

Run a health-check and consistency pass on the knowledge base. Finds problems, suggests fixes, and uses graph algorithms to predict missing connections.

Can be run manually or scheduled on a cron.

## Prerequisites

### Locate the Knowledge Base

Follow these steps in order to determine which KB to operate on:

1. **User specified a KB by name.** If the user said something like "maintain research-kb", look up that name in `.kb/registry.md` to get the absolute path.
2. **Check the current directory.** If `.kb/config.md` exists in the current working directory, use this directory as the KB root.
3. **Read the registry.** Read `.kb/registry.md`:
   - One KB listed → use it.
   - Multiple KBs listed → list them and ask the user which one.
   - No registry or empty → tell the user to run kb-create first.

Once resolved, set `{KB_ROOT}` to the KB's absolute path, then:
- Read `{KB_ROOT}/.kb/config.md` to get the qmd collection name
- Read `{KB_ROOT}/CONSTITUTION.md` for entity types, connection rules, and quality standards

All paths below are relative to `{KB_ROOT}`.

## Maintenance Procedure

Run these checks in order. Report findings as you go.

### 1. Orphan Check

Find pages with no inbound `[[wikilinks]]` (nothing links to them).

- Scan all markdown files in `{KB_ROOT}/wiki/`
- Build a reverse link map (page → pages that link to it)
- Any page with 0 inbound links is an orphan
- **Action**: Connect orphans to relevant pages, or flag for user review

### 2. Contradiction Scan

Look for claims in different pages that conflict:

- Read pages on related topics (use the graph neighborhood)
- Flag any factual contradictions
- **Action**: Note contradictions in both pages, or create a synthesis page analyzing the conflict (use `synthesis-type: contradiction` and follow the synthesis page structure defined in `skills/kb-query/references/query-patterns.md`)

### 3. Staleness Check

Identify pages not updated recently that may be outdated:

- Read `updated` frontmatter from each page
- Pages not updated in 30+ days with fewer than 3 sources may be stale
- **Action**: Flag for review, suggest re-evaluating with recent sources

### 4. Missing Pages (Dead Links)

Find `[[wikilinks]]` that point to pages that don't exist:

- Parse all wikilinks across the wiki
- Check which targets have no corresponding file
- **Action**: Create stub pages or remove dead links

### 5. Connection Density

Identify pages with low link counts:

- Pages with fewer than 2 outbound links may be underconnected
- Pages with fewer than 2 inbound links may be poorly integrated
- **Action**: Add links where relationships exist but aren't documented

### 6. Link Prediction (Algorithmic)

Run graph analysis scripts to surface missing connections:

```bash
# Jaccard similarity — find pages with similar neighborhoods
python scripts/jaccard-similarity.py {KB_ROOT}/wiki/ --threshold 0.3

# Common neighbors — pages that should link but don't
python scripts/common-neighbors.py {KB_ROOT}/wiki/ --min-common 2

# Adamic-Adar — weighted link prediction favoring rare intermediaries
python scripts/adamic-adar.py {KB_ROOT}/wiki/ --top 20

# Cluster detection — find densely connected groups
python scripts/cluster-detection.py {KB_ROOT}/wiki/
```

Review the suggestions. Add links where the prediction makes semantic sense (not all algorithmic suggestions are meaningful).

### 7. Synthesis Opportunities

Surface places in the graph where a synthesis page would add value — connecting distant clusters, documenting cross-cutting patterns, or pre-computing frequently needed traversals.

1. **Cluster bridging** — From cluster detection output (Step 6), identify pairs of clusters connected by only 1-2 bridge pages. A synthesis page could strengthen the bridge and make the connection explicit.
2. **Cross-subdirectory connections** — From Jaccard/Adamic-Adar output, find high-scoring page pairs in *different* subdirectories (e.g., an entity and a concept that relate but aren't directly linked). These are synthesis candidates.
3. **Synthesis staleness** — For existing synthesis pages with a `derived-from` frontmatter field, compare the synthesis `updated` date against `updated` dates of its derived-from pages. If source pages are newer, the synthesis may be stale. If `derived-from` is missing, suggest adding it.

**Report format:**
```markdown
### Synthesis Opportunities
- **New**: [description] — connects [[A]], [[B]], [[C]] across entities/concepts
- **Stale**: [[Existing Synthesis]] — derived-from pages updated since last synthesis update
```

**Action — interactive runs:** Present the list to the user. For approved candidates, create synthesis pages immediately following the structure in `skills/kb-query/references/query-patterns.md`. Do NOT auto-create.

**Action — scheduled/autonomous runs:** If the user has explicitly configured maintenance to run autonomously (e.g., on a cron schedule with auto-synthesis enabled), create synthesis pages for **clear-cut cases only**:
- Contradictions between pages that directly conflict on a specific factual claim
- Clusters of 5+ pages sharing 3+ common concepts with no existing synthesis connecting them
- Existing synthesis pages whose derived-from pages have all been updated since the synthesis

Skip ambiguous cases — if the synthesis would require subjective judgment about what pattern to highlight or which framing to use, log the opportunity instead and leave it for an interactive session.

### 8. Concept Consolidation

Look for near-duplicate concepts:

- Pages with very similar titles or content that should be merged
- Use Jaccard similarity output to identify candidates
- **Action**: Merge duplicates, redirect links

### 9. Concept Splitting

Look for pages that have grown too large:

- Pages over 500 lines may need to be split into sub-pages
- Hub pages linking to 20+ other pages may be doing too much
- **Action**: Propose splits to the user

### 10. qmd Sync

Keep the search index current:

```bash
qmd update --collections <kb-name>
qmd embed
```

This catches any files that were created, changed, or deleted since the last sync.

### 11. Log Compaction

Compact old log entries:

- Entries older than 7 days → summarize into weekly summaries
- Keep the last 7 days in full detail
- Weekly summary format:
  ```markdown
  ---
  ## Weekly Summary: YYYY-MM-DD to YYYY-MM-DD
  - N imports (types breakdown)
  - N queries (N filed as synthesis)
  - Maintenance: findings and actions
  - Structure changes: if any
  ```

### 12. Log Entry

Insert the following entry into LOG.md **directly below the file's header block** (above all existing entries — the log is reverse-chronological, newest first):

```markdown
## [YYYY-MM-DD HH:MM] maintain | Health Check

- Orphans found: N (connected: N, flagged: N)
- Dead links: N (fixed: N)
- Stale pages: N (flagged for review)
- Link predictions: N suggested (N added)
- Contradictions: N found
- Synthesis: N opportunities found (N created, N stale flagged)
- qmd: synced
- Log: compacted entries older than 7 days
```

## Report

After running all checks, present:
- Summary of findings (what's healthy, what needs attention)
- Actions taken automatically
- Questions for the user (contradictions to resolve, merges to approve)
- Graph health metrics (total pages, total links, average links per page, orphan count)

## Graph Analysis Scripts

All scripts parse `[[wikilinks]]` from markdown files in the wiki directory. They output ranked suggestions — the agent or user decides which to act on.

- **`jaccard-similarity.py`** — Jaccard index of link neighborhoods for all page pairs
- **`common-neighbors.py`** — Pages sharing many neighbors that aren't directly linked
- **`adamic-adar.py`** — Weighted common neighbors favoring rare intermediaries
- **`cluster-detection.py`** — Densely connected clusters and bridge pages

For detailed script usage, load `references/maintenance-ops.md`.
