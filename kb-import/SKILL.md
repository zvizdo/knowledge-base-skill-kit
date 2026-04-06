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
3. `{KB_ROOT}/INDEX.md` (to know what already exists)
4. Recent entries in `{KB_ROOT}/LOG.md` (first 30 lines — for recent context)

### Step 4 — Extract & Create

Follow the import procedure's extraction steps:

1. Read the source document thoroughly
2. Identify entities, concepts, findings, and relationships as defined by the procedure
3. For each entity found:
   - Check if a page already exists (search INDEX.md, then `qmd search "<entity name>" -c <collection>`)
   - If exists: **update** the existing page with new information, adding the new source to its `sources` frontmatter
   - If new: **create** a new page in `{KB_ROOT}/wiki/entities/` using the wiki page format (see below)
4. For each concept touched:
   - Same create-or-update logic as entities
5. If the source warrants it, create a source summary page (type: `source-summary`) that links to all entities and concepts it touched

### Step 5 — Back-Link Pass

This is critical. After creating/updating pages:

1. For every NEW page created, search existing wiki pages for mentions of the new page's topic
   - Use `qmd search "<page topic>" -c <collection>` to find semantically related existing pages
   - Add `[[wikilinks]]` from those existing pages to the new page where relevant
2. For every UPDATED page, check if new content creates connections to pages not yet linked
3. Ensure every new page has at least 2 inbound `[[wikilinks]]` (CONSTITUTION minimum)

### Step 6 — Update INDEX.md

For every page created or updated:
- Add new entries to the appropriate section (Entities, Concepts, Synthesis)
- Update existing entries if their summary changed
- Format: `- [[Page Name]] — one-line summary (source count: N, last updated: YYYY-MM-DD)`

### Step 7 — Update LOG.md

Prepend an entry to LOG.md:
```markdown
## [YYYY-MM-DD HH:MM] import | "Source Title or Description"
- Procedure used: <procedure-name>
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
- What pages were created (with `[[wikilinks]]`)
- What pages were updated
- How many new connections were made
- Any contradictions found with existing content
- Any questions or ambiguities the user should resolve

## Wiki Page Format

Every wiki page follows this structure:

```markdown
---
type: entity | concept | synthesis | source-summary
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

Domain-specific frontmatter fields are defined in the CONSTITUTION.

## Key Principles

- **A single source may touch many wiki pages.** A research paper might create 1 summary, update 3 concepts, add to 2 entities, and strengthen a synthesis page.
- **Always update, never duplicate.** If a page exists, add to it. Don't create a second page for the same entity.
- **The back-link pass is not optional.** New pages must be woven into the existing graph.
- **Cite sources.** Every claim on a wiki page should trace back to a source in `raw/`.

For detailed guidance on defining new import procedures, load `references/import-guide.md`.
