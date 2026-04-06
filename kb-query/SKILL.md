---
name: kb-query
description: Query the knowledge base using graph-traversal-first strategy — finds entry points via INDEX or qmd, walks wikilink connections to gather context, synthesizes answers grounded in the graph, and optionally files results back as synthesis pages.
---

# kb-query — Query the Knowledge Base

Ask questions of the knowledge base. The key insight: **the knowledge is in the connections, not just the pages.** Querying exploits the graph structure by traversing `[[wikilinks]]` rather than just retrieving isolated documents.

## Prerequisites

### Locate the Knowledge Base

Follow these steps in order to determine which KB to operate on:

1. **User specified a KB by name.** If the user said something like "query research-kb", look up that name in `.kb/registry.md` to get the absolute path.
2. **Check the current directory.** If `.kb/config.md` exists in the current working directory, use this directory as the KB root.
3. **Read the registry.** Read `.kb/registry.md`:
   - One KB listed �� use it.
   - Multiple KBs listed → list them and ask the user which one.
   - No registry or empty → tell the user to run kb-create first.

Once resolved, set `{KB_ROOT}` to the KB's absolute path, then:
- Read `{KB_ROOT}/.kb/config.md` to get the qmd collection name
- Read `{KB_ROOT}/CONSTITUTION.md` for domain context

All paths below are relative to `{KB_ROOT}`.

## Query Flow

### Step 1 — Understand the Question

Parse what the user is asking. Classify the query type:

- **Factual**: "What do we know about X?" → Find and summarize the relevant page(s)
- **Relational**: "How does X relate to Y?" → Find paths between X and Y in the graph
- **Analytical**: "Compare X and Y" → Gather both subgraphs and synthesize
- **Gap**: "What don't we know about X?" → Find what's missing or underconnected
- **Exploratory**: "What's interesting about X?" → Traverse the neighborhood and surface patterns

### Step 2 — Find Entry Points

Find 1-3 wiki pages most relevant to the question. Use both:

1. **INDEX.md scan** — Browse the catalog for exact or near matches
2. **qmd semantic search** — `qmd vsearch "<query>" -c <collection>` for conceptually related pages

These are starting nodes, not the answer.

### Step 3 — Map the Neighborhood

For each entry point, understand the local graph:

- Run `scripts/neighborhood.py {KB_ROOT}/wiki/ <start-page> --hops 2` to get all pages within 2 hops
- This scopes what the agent should read

For relational queries specifically:
- Run `scripts/shortest-path.py {KB_ROOT}/wiki/ <page-A> <page-B>` to find how two pages connect
- Run `scripts/shared-connections.py {KB_ROOT}/wiki/ <page-A> <page-B>` to find common neighbors

### Step 4 — Traverse and Read

Walk the graph from entry points:

1. Read each entry point page
2. Follow `[[wikilinks]]` that seem relevant to the question
3. Read those linked pages
4. Follow their links if they lead toward the answer
5. Collect facts, relationships, and patterns along the traversal

The agent is walking a subgraph, not searching a flat document store.

### Step 5 — Synthesize

Construct the answer from the traversal:

- **Cite the paths**: Reference not just pages but connections: "[[Concept A]] links to [[Entity B]] through [[Concept C]], suggesting..."
- **Ground in evidence**: Every claim should trace to a wiki page, which traces to a source
- **Flag gaps**: If the question can't be fully answered, say what's missing
- **Note contradictions**: If different pages disagree, surface both perspectives

### Step 6 — Choose Output Format

Match the format to the question:

| Query Type | Output Format |
|------------|--------------|
| Factual | Prose with `[[wikilink]]` citations |
| Relational | Path explanation with intermediate nodes |
| Analytical | Comparison table or structured analysis |
| Gap | "What we know" vs "What's missing" breakdown |
| Exploratory | Key findings with connection map |

### Step 7 — Optionally File Back

If the answer is worth keeping:

1. Ask the user: "This seems worth saving. Want me to file it as a synthesis page?"
2. If yes: create a new page in `{KB_ROOT}/wiki/synthesis/` with type `synthesis`
3. Add `[[wikilinks]]` to all pages referenced in the answer
4. Perform a back-link pass (add links from referenced pages back to the new synthesis)
5. Update INDEX.md
6. Prepend to LOG.md
7. Run `qmd update --collections <kb-name> && qmd embed`

## Graph Scripts

Three Python scripts for graph analysis. All parse `[[wikilinks]]` directly from markdown files.

### shortest-path.py

Find the shortest path(s) between two pages via `[[wikilinks]]`.

```bash
python scripts/shortest-path.py {KB_ROOT}/wiki/ "<Page A>" "<Page B>"
```

Output: All shortest paths, plus near-shortest alternatives. The path itself is often the answer to "how does X relate to Y?"

### neighborhood.py

Get all pages within N hops of a starting page.

```bash
python scripts/neighborhood.py {KB_ROOT}/wiki/ "<Page Name>" --hops 2
```

Output: List of pages grouped by hop distance. Useful for scoping what to read.

### shared-connections.py

Find pages that two notes both link to or are both linked from.

```bash
python scripts/shared-connections.py {KB_ROOT}/wiki/ "<Page A>" "<Page B>"
```

Output: Common outbound links, common inbound links. Reveals hidden commonalities.

## LOG Entry

After answering a query (whether filed or not):

```markdown
## [YYYY-MM-DD HH:MM] query | "User's question"
- Entry points: [[Page1]], [[Page2]]
- Traversed: [[Page1]] → [[Page3]] → [[Page4]]
- Answer type: factual | relational | analytical | gap | exploratory
- Filed as: [[Synthesis Page Title]] (or "not filed")
```
