# Maintenance Operations — Detailed Reference

## Graph Analysis Scripts

All four scripts share a common foundation: they parse `[[wikilinks]]` from markdown files to build an adjacency graph, then apply graph theory algorithms to surface insights.

### jaccard-similarity.py

**What it does**: For every pair of pages, computes the Jaccard index of their link neighborhoods:

```
J(A, B) = |neighbors(A) ∩ neighbors(B)| / |neighbors(A) ∪ neighbors(B)|
```

High Jaccard similarity + no direct link = strong candidate for a missing connection.

**Usage**:
```bash
python scripts/jaccard-similarity.py <wiki-dir> [--threshold 0.3] [--top 20]
```

**Interpreting results**:
- Score > 0.5: Very likely missing link — these pages have highly overlapping neighborhoods
- Score 0.3–0.5: Probable missing link — worth reviewing
- Score < 0.3: Weak signal — may or may not warrant a link

### common-neighbors.py

**What it does**: Finds page pairs that share many common neighbors but don't link to each other directly. Classic link prediction heuristic from graph theory.

**Usage**:
```bash
python scripts/common-neighbors.py <wiki-dir> [--min-common 2] [--top 20]
```

**Interpreting results**:
- The more common neighbors, the stronger the prediction
- Review the actual common neighbors to understand WHY the prediction was made
- Not all common neighbors are meaningful — two pages might share hubs without being related

### adamic-adar.py

**What it does**: Like common neighbors, but weighs shared connections through rare (low-degree) pages more heavily than through hub pages. Based on the Adamic-Adar index from social network analysis.

```
AA(A, B) = Σ 1/log(degree(z)) for all common neighbors z
```

A shared connection through a page with only 3 links is more informative than one through a page with 30 links.

**Usage**:
```bash
python scripts/adamic-adar.py <wiki-dir> [--top 20]
```

**Interpreting results**:
- Higher scores = stronger predictions
- These predictions tend to be more "interesting" than raw common neighbors because they surface non-obvious connections
- Good for finding connections through niche concepts rather than broad categories

### cluster-detection.py

**What it does**: Identifies densely connected clusters of pages and pages that bridge between clusters. Uses a label propagation algorithm.

**Usage**:
```bash
python scripts/cluster-detection.py <wiki-dir> [--min-cluster 3]
```

**Interpreting results**:
- **Clusters**: Groups of tightly connected pages (likely represent a coherent topic area)
- **Bridge pages**: Pages that connect multiple clusters (important structural nodes)
- **Over-connected hubs**: Pages belonging to many clusters may need splitting
- **Isolated clusters**: Clusters with no bridges to other clusters may indicate knowledge silos

## Maintenance Scheduling

The maintenance procedure is platform-agnostic. It's a sequence of steps any agent can follow.

**For Claude Code**: Use the cron/schedule feature to run maintenance weekly.

**For other platforms**: Map to whatever scheduling mechanism is available.

**Suggested frequency**:
- **After every 5-10 imports**: Run a quick maintenance (orphan check + link prediction + index sync + qmd sync)
- **Weekly**: Full maintenance pass (all 12 steps)
- **Monthly**: Deep maintenance (full pass + review all stale pages + consider structural changes)

## Common Maintenance Patterns

### The Growing Hub Problem

As a KB grows, some concept pages become hubs — they link to everything. This is natural but can reduce the signal value of those links.

Signs: A concept page with 20+ outbound links. Cluster detection shows it bridging many clusters.

Fix: Split the hub into sub-concepts. E.g., [[Attachment Theory]] might split into [[Anxious Attachment]], [[Avoidant Attachment]], [[Secure Attachment]] with the parent page becoming an overview.

### The Orphan Island Problem

A batch import creates several new pages that link to each other but not to the rest of the wiki.

Signs: Multiple orphans found after an import. Cluster detection shows a new isolated cluster.

Fix: Run Jaccard/Adamic-Adar to find connections to the existing graph. Manually review and add links.

### The Stale Core Problem

Early pages that formed the KB's foundation haven't been updated as newer, better sources arrived.

Signs: High-degree pages with old `updated` dates. Content that contradicts newer synthesis pages.

Fix: Re-read the stale page against recent sources. Update or flag contradictions.

## Log Compaction Details

During compaction:

1. Read LOG.md
2. Identify entries older than 7 days
3. Group old entries by week (Monday–Sunday)
4. For each week, write a summary:
   - Count of operations by type (import, query, maintain, evolve)
   - Key pages created or significantly updated
   - Notable findings or decisions
5. Replace the detailed entries with the weekly summary
6. Keep all entries from the last 7 days unchanged

The goal: the top of LOG.md is always fast to scan for recent context, while the bottom preserves a compressed historical record.
