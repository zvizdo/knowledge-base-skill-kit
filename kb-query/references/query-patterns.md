# Query Patterns — Detailed Reference

## Graph-Traversal-First Philosophy

Traditional RAG: embed query → retrieve chunks → generate answer.

Knowledge base querying: find entry nodes → walk the graph → synthesize from connections.

The difference: RAG treats documents as isolated chunks. Graph traversal treats pages as nodes in a network where **the relationships carry as much meaning as the content**.

When answering "How does X relate to Y?", the shortest path between X and Y through intermediary concept pages IS the answer. No embedding similarity score can give you that.

## Query Type Deep Dives

### Factual Queries

"What do we know about attachment theory?"

1. Find [[Attachment Theory]] via INDEX.md
2. Read it
3. Follow its `## Related` links to see connected entities and concepts
4. Synthesize a comprehensive answer from the page and its immediate neighbors

Keep it grounded — don't speculate beyond what the wiki contains.

### Relational Queries

"How does running relate to conscientiousness?"

1. Find entry points: [[Running]], [[Conscientiousness]]
2. Run `shortest-path.py` between them
3. Read every page on the path(s)
4. The path tells the story: maybe [[Running]] → [[Discipline Signals]] → [[Conscientiousness]]
5. Answer describes the connection through intermediary concepts

If no path exists, that's informative too: "These concepts aren't connected in the KB yet."

### Analytical Queries

"Compare Person A and Person B"

1. Find both entity pages
2. Run `shared-connections.py` to find what they have in common
3. Run `neighborhood.py` on each to see their local graphs
4. Build a comparison across dimensions defined in the CONSTITUTION's evaluation criteria
5. Output as a structured table or side-by-side analysis

### Gap Queries

"What don't we know about this topic?"

1. Find the topic page
2. Check its source count and last updated date
3. Look for stub links (`[[Page]]` references with no actual page)
4. Check if the CONSTITUTION defines entity types or concept areas not yet covered
5. Report what exists vs what's missing

### Exploratory Queries

"What's interesting in the KB right now?"

1. Run `neighborhood.py` on high-degree nodes (pages with many connections)
2. Look for recent imports (read LOG.md)
3. Find unexpected connections (pages linked through surprising intermediaries)
4. Surface clusters and bridges

## Using qmd for Entry Point Discovery

Three search modes, use the right one:

- `qmd search "exact terms" -c <collection>` — BM25 keyword search. Fast. Use when you know the exact terms.
- `qmd vsearch "conceptual query" -c <collection>` — Vector semantic search. Use when the question uses different words than the wiki pages.
- `qmd query "complex question" -c <collection>` — Hybrid + LLM re-ranking. Best quality, slowest. Use for ambiguous or complex queries.

**Always specify the collection** with `-c <collection>`. Never run unscoped searches.

After finding entry points via qmd, switch to graph traversal. qmd finds the door; the graph walk finds the answer.

## Filing Answers as Synthesis Pages

Good candidates for filing:
- Comparisons that took significant traversal to construct
- Relationship analyses that revealed non-obvious connections
- Gap analyses that map what's known vs unknown
- Any answer the user says "that's useful, keep it"

When filing, the synthesis page should:
- Have `type: synthesis` in frontmatter
- List all source pages in its `## Related` section
- Be written to stand alone (someone reading just that page should understand it)
- Be added to the Synthesis section of INDEX.md

Bad candidates for filing:
- Simple factual lookups (the answer is already in the entity page)
- Queries about KB health or status (use maintenance for that)
