# Knowledge Base Skill Kit

A skill kit where LLMs build and maintain a persistent, interlinked wiki from your sources — not RAG. Five skills handle creation, import, graph-traversal querying, maintenance, and structural evolution. Plain markdown, Obsidian-compatible, [agent-skills-spec](https://agentskills.io/specification) compliant.

This is not a one-time "sources to graph" conversion. The knowledge base is a living system — it grows with every import, sharpens with every query, and self-corrects through periodic maintenance. Each cycle of import → query → maintain compounds the value of what came before. The more you use it, the more it knows, and the better its answers get.

## How It Works

The user never writes the wiki. The LLM writes and maintains all of it. The user curates sources, directs analysis, and asks questions.

1. **Create** a knowledge base with a guided wizard that defines purpose, entities, concepts, and import procedures
2. **Import** sources — the LLM extracts knowledge, creates wiki pages, and weaves them into the graph via `[[wikilinks]]`
3. **Query** using graph-traversal-first strategy — walk connections between pages, not just search isolated documents
4. **Maintain** with health checks, link prediction algorithms, synthesis opportunities, and consistency passes
5. **Evolve** the structure as your understanding of the domain deepens

Knowledge compounds over time. Early imports create isolated pages; later imports discover connections to existing pages. Queries surface patterns across the graph and can be filed back as synthesis pages — cached inferences that save future queries from re-traversing the same subgraph. Maintenance predicts missing links, flags contradictions, and identifies synthesis opportunities. The KB gets denser, more connected, and more useful with every operation.

## Skills

| Skill | Description |
|-------|-------------|
| `kb-create` | Guided wizard — interactively defines purpose, entities, concepts, import procedures, scaffolds the KB, configures qmd search |
| `kb-import` | Import orchestrator — processes sources into wiki pages using import procedures, cross-links, syncs the search index |
| `kb-query` | Graph-traversal query engine — finds entry points, walks wikilinks, synthesizes answers, optionally files results as synthesis pages |
| `kb-maintain` | Health checks and graph analysis — orphan detection, link prediction, synthesis opportunities, contradiction scanning, consistency enforcement |
| `kb-evolve` | Structural evolution — add procedures, update constitution, restructure wiki, extend tooling |

## Structure

```
knowledge-base-skill-kit/
├── kb-create/
│   ├── SKILL.md                    # Creation wizard
│   ├── references/
│   │   └── creation-guide.md       # Deep reference for scaffolding
│   └── assets/
│       └── templates/
│           ├── constitution.md     # CONSTITUTION template
│           ├── config.md           # .kb/config template
│           ├── log.md              # LOG template
│           └── import-procedure.md # Import procedure template
├── kb-import/
│   ├── SKILL.md                    # Import orchestrator
│   └── references/
│       └── import-guide.md         # Import procedure authoring guide
├── kb-query/
│   ├── SKILL.md                    # Graph-traversal query engine
│   ├── scripts/
│   │   ├── shortest-path.py        # Find shortest path(s) between two pages
│   │   ├── neighborhood.py         # All pages within N hops of a starting page
│   │   ├── shared-connections.py   # Common connections between two pages
│   │   └── frontmatter.py          # Extract frontmatter fields without reading full pages
│   └── references/
│       └── query-patterns.md       # Query types and output formats
├── kb-maintain/
│   ├── SKILL.md                    # Maintenance procedures
│   ├── scripts/
│   │   ├── jaccard-similarity.py   # Predict missing links via Jaccard index
│   │   ├── common-neighbors.py     # Surface pages that should link but don't
│   │   ├── adamic-adar.py          # Weighted link prediction
│   │   └── cluster-detection.py    # Find clusters and bridge pages
│   └── references/
│       └── maintenance-ops.md      # Detailed maintenance procedures
├── kb-evolve/
│   ├── SKILL.md                    # Evolution operations
│   └── references/
│       └── evolution-guide.md      # Restructuring and extension guide
└── README.md                       # This file
```

## Dependencies

### Required

- **[qmd](https://github.com/tobi/qmd)** — Local hybrid search engine (BM25 + vector + LLM re-ranking). All on-device.
  ```bash
  bun install -g @tobilu/qmd
  ```
  Requires [Bun](https://bun.sh) >= 1.0.0. On macOS, may also need `brew install sqlite`.

- **[qmd agent skill](https://github.com/levineam/qmd-skill)** — Companion skill that teaches your agent how to use qmd effectively. Install alongside this skill kit in your agent's skills directory.

- **Python 3.10+** — For the graph analysis scripts. No external packages required (stdlib only).

### Recommended

- **[Obsidian](https://obsidian.md)** — Free markdown editor with graph view. The wiki uses Obsidian-compatible `[[wikilinks]]`, so you get interactive graph visualization out of the box.

- **Git** — Version control for the knowledge base. Recommended for tracking wiki evolution and safe rollbacks before restructuring.

## Compatible Agents

This skill kit follows the [Agent Skills specification](https://agentskills.io/specification) and works with any compliant agent:

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- [OpenClaw](https://github.com/nicobailon/openclaw)
- [Codex](https://github.com/openai/codex)
- Any agent supporting SKILL.md discovery and progressive disclosure

## What Gets Created

When you run `kb-create`, it scaffolds:

```
my-knowledge-base/
├── CONSTITUTION.md       # Governing document — purpose, entities, extraction rules
├── LOG.md                # Chronological operation log (newest first)
├── imports/              # Import procedure definitions
│   ├── _template.md      # Template for new procedures
│   └── *.md              # One per source type
├── raw/                  # Immutable source files
├── wiki/                 # LLM-maintained synthesis layer
│   ├── entities/         # Atomic pages for concrete things
│   ├── concepts/         # Framework and theory pages
│   ├── synthesis/        # Cached inferences — derived relationships, patterns, comparisons
│   └── [custom]/         # Domain-specific directories
└── .kb/
    └── config.md         # KB name, absolute path, qmd collection, preferences
```

A **registry file** is also created at `.kb/registry.md` in the agent's root working directory. This is how skills find KBs when multiple exist — a simple markdown table mapping names to absolute paths. The resolution protocol checks: (1) user-specified name, (2) current directory, (3) registry lookup.

## Design Principles

1. **The user never writes the wiki.** The LLM handles creation, updating, cross-referencing, and maintenance.
2. **Knowledge compounds.** Every import, query, and maintenance pass makes the KB more valuable.
3. **Everything is plain markdown.** No databases, no proprietary formats. Git-friendly, Obsidian-compatible.
4. **The CONSTITUTION is the brain.** It tells the LLM what to care about, extract, and connect.
5. **Import procedures are reusable prompts.** Domain expertise encoded once, applied consistently.
6. **The graph is emergent.** Connections arise from `[[wikilinks]]` in content, not from a separate database.
7. **Portability first.** Standard agent skills spec. No platform lock-in.

## Getting Started

1. Install dependencies (qmd, qmd skill, Python 3.10+)
2. Install this skill kit in your agent's skills directory
3. Run `kb-create` and follow the guided wizard
4. Drop source files into `raw/` and run `kb-import`
5. Ask questions with `kb-query`
6. Run `kb-maintain` periodically to keep the graph healthy
