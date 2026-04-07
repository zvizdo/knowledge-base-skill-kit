---
name: kb-import
description: Import orchestrator — processes a new source into the knowledge base wiki using the appropriate import procedure, creates/updates wiki pages, cross-links, and syncs the search index.
---

# kb-import — Import Source into Knowledge Base

Process a new source into the wiki. The LLM reads the source, applies the right import procedure, creates and updates wiki pages, performs a back-link pass, and keeps everything in sync.

## Prerequisites

### Locate the Knowledge Base

Follow these steps in order to determine which KB to operate on:

1. **User specified a KB by name.** If the user said something like "import into research-kb", look up that name in `.kb/registry.md` to get the absolute path.
2. **Check the current directory.** If `.kb/config.md` exists in the current working directory, use this directory as the KB root.
3. **Read the registry.** Read `.kb/registry.md`:
   - One KB listed → use it.
   - Multiple KBs listed → list them and ask the user which one.
   - No registry or empty → tell the user to run kb-create first.

Once resolved, set `{KB_ROOT}` to the KB's absolute path, then:
- Read `{KB_ROOT}/.kb/config.md` to get the KB name and qmd collection name
- Read `{KB_ROOT}/CONSTITUTION.md` to understand extraction rules and connection rules

All paths below are relative to `{KB_ROOT}`.

## Import Flow

### Step 1 — Receive Source

The user provides a source in one of these forms:
- A file path (PDF, text, markdown, image)
- Pasted text
- A URL to fetch
- A screenshot

Move or copy the source file to the appropriate `{KB_ROOT}/raw/` subdirectory as defined by the import procedure.

### Step 2 — Select Import Procedure

Identify which import procedure applies:

1. Read all procedure files in `{KB_ROOT}/imports/` (skip `_template.md`)
2. Match based on the procedure's `trigger` field and the source type
3. If multiple procedures could apply, ask the user which one to use
4. If no procedure matches, ask the user if they want to create a new one (via kb-evolve) or do a one-off import using the CONSTITUTION's general extraction rules

### Step 3 — Read Context

Before processing, read:
1. The selected import procedure (`{KB_ROOT}/imports/<name>.md`)
2. `{KB_ROOT}/CONSTITUTION.md` (extraction rules, connection rules, entity types, concept types)
3. Recent entries in `{KB_ROOT}/LOG.md` (first 30 lines — for recent context)
4. Scan existing pages with `glob wiki/**/*.md` and `qmd search` to know what already exists

### Step 4 — Summarize Source

Every import produces a source summary page — a first-class node in the wiki graph.

1. Read the source document thoroughly
2. Create a summary page in `{KB_ROOT}/wiki/<procedure-name>/` (e.g. `wiki/research-papers/paper-title.md`)
   - Create the `wiki/<procedure-name>/` folder if it doesn't exist yet
3. The summary page must:
   - Use `type: source-summary` in frontmatter
   - Link to the raw file in its `sources` field (e.g. `sources: [raw/papers/original.pdf]`)
   - Contain a structured summary of the source's key content, findings, and arguments
   - Include `[[wikilinks]]` to all entities and concepts that will be created or updated in Step 5
4. Follow the import procedure's summary guidance (if defined) for what to emphasize

This makes the summary visible and linkable in Obsidian as part of the wiki graph.

### Step 5 — Extract & Create

Follow the import procedure's extraction steps to create or update entity and concept pages:

1. **Entities** — concrete things: people, organizations, tools, events, etc. These go in `wiki/entities/`.
   - For each entity identified in the source:
     - Check if a page already exists (use `qmd search "<entity name>" -c <collection>` and `glob wiki/**/<slug>*.md`)
     - If exists: **update** the existing page with new information, adding the new source to its `sources` frontmatter
     - If new: **create** a new page in `{KB_ROOT}/wiki/entities/` using the wiki page format (see below)

2. **Concepts** — frameworks, theories, models, abstract analytical lenses. These go in `wiki/concepts/`.
   - For each concept identified in the source:
     - Check if a page already exists (use `qmd search "<concept name>" -c <collection>` and `glob wiki/**/<slug>*.md`)
     - If exists: **update** the existing page with new information or supporting evidence, adding the new source to its `sources` frontmatter
     - If new: **create** a new page in `{KB_ROOT}/wiki/concepts/` using the wiki page format (see below)

3. Ensure all new entity and concept pages link back to the source summary page created in Step 4

4. **Synthesis check** — Search for existing synthesis pages whose `derived-from` frontmatter field includes any entity or concept page that was just created or updated. Note these in the import report (Step 9) as potentially needing review. Do not auto-update synthesis pages during import.

The CONSTITUTION defines which specific entity types and concept frameworks apply to this KB. Consult it to decide what qualifies as an entity vs a concept.

### Step 6 — Back-Link Pass

This is critical. After creating/updating pages:

1. For every NEW page created (including the source summary), search existing wiki pages for mentions of the new page's topic
   - Use `qmd search "<page topic>" -c <collection>` to find semantically related existing pages
   - Add `[[wikilinks]]` from those existing pages to the new page where relevant
2. For every UPDATED page, check if new content creates connections to pages not yet linked
3. Ensure every new page has at least 2 inbound `[[wikilinks]]` (CONSTITUTION minimum)

### Step 7 — Update LOG.md

Insert the following entry into LOG.md **directly below the file's header block** (above all existing entries — the log is reverse-chronological, newest first):
```markdown
## [YYYY-MM-DD HH:MM] import | "Source Title or Description"
- Procedure used: <procedure-name>
- Summary: wiki/<procedure-name>/<summary-page>.md
- Created: [[New Page 1]], [[New Page 2]]
- Updated: [[Existing Page 1]], [[Existing Page 2]]
- Source: raw/path/to/source.ext
- Back-links added: N new connections
```

### Step 8 — Sync Search Index

```bash
qmd update --collections <kb-name> && qmd embed
```

### Step 9 — Report

Tell the user:
- The source summary page created (with `[[wikilink]]`)
- What entity and concept pages were created (with `[[wikilinks]]`)
- What pages were updated
- How many new connections were made
- Any contradictions found with existing content
- Synthesis pages that may need review: `[[Page]]` (reason: derived-from page `[[X]]` was updated)
- Any questions or ambiguities the user should resolve

## Wiki Page Format

Every wiki page follows this structure:

```markdown
---
type: entity | concept | synthesis | source-summary
summary: "One-line description of what this page covers"
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources: [raw/path/to/source1.ext, raw/path/to/source2.ext]
tags: [domain-specific tags]
---

# Page Title

[Content organized with markdown headers]

## Related
- [[Link1]] — relationship description
- [[Link2]] — relationship description
```

**Page locations by type:**
- `entity` → `wiki/entities/`
- `concept` → `wiki/concepts/`
- `synthesis` → `wiki/synthesis/`
- `source-summary` → `wiki/<procedure-name>/` (named after the import procedure that created it)

**Synthesis pages use additional frontmatter fields:**
- `synthesis-type`: comparison | pattern | contradiction | gap-analysis | framework-application
- `derived-from`: list of wiki page slugs whose content was used to produce the synthesis (enables staleness detection and impact analysis)

See `kb-query/references/query-patterns.md` for the full synthesis page structure.

Domain-specific frontmatter fields are defined in the CONSTITUTION.

## Key Principles

- **A single source may touch many wiki pages.** A research paper might create 1 summary, update 3 concepts, and add to 2 entities. If updated pages appear in the `derived-from` field of existing synthesis pages, flag those synthesis pages for review in the report.
- **Always update, never duplicate.** If a page exists, add to it. Don't create a second page for the same entity.
- **The back-link pass is not optional.** New pages must be woven into the existing graph.
- **Cite sources.** Every claim on a wiki page should trace back to a source in `raw/`.

For detailed guidance on defining new import procedures, load `references/import-guide.md`.
