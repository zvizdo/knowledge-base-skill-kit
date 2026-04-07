---
name: kb-create
description: Guided wizard that scaffolds a new personal knowledge base — interactively defines purpose, entities, concepts, import procedures, and folder structure, then generates all files and configures qmd search.
---

# kb-create — Knowledge Base Creation Wizard

Create a new knowledge base through a conversational, phased process. Each phase builds on the previous. The wizard probes, clarifies, and reflects back understanding before moving on.

## Prerequisites

Before starting, verify these are installed:

1. **qmd CLI** — local hybrid search engine (BM25 + vector + LLM re-ranking)
   - Install: `bun install -g @tobilu/qmd`
   - Requires: Bun >= 1.0.0. On macOS, may also need `brew install sqlite`.
   - GitHub: [tobi/qmd](https://github.com/tobi/qmd)

2. **qmd agent skill** — teaches the agent how to use qmd effectively
   - GitHub: [levineam/qmd-skill](https://github.com/levineam/qmd-skill)
   - Install into your agent's skills directory alongside this skill kit.

If either is missing, guide the user through installation before proceeding.

## Creation Flow

Run all 5 phases in order. Be conversational — ask questions, probe for clarity, reflect back what you understood, and get confirmation before moving on. Do NOT rush through phases as a form.

### Phase 1 — Purpose & Domain

Ask the user:
- "What is this knowledge base for?"
- "What domain does it cover?"
- "What is the long-term question you're trying to answer over time?"

Extract from their answers:
- Purpose statement
- Domain boundaries
- North star question

Reflect back a summary and confirm before continuing.

### Phase 2 — Entities & Concepts

Ask the user:
- "What kinds of things should get their own pages?" (e.g., people, papers, companies, concepts)
- "What frameworks or mental models should be applied when analyzing sources?"
- "Are there rating or scoring systems that matter?"

Extract:
- Entity types (what gets a page in `wiki/entities/`)
- Concept frameworks (what gets a page in `wiki/concepts/`)
- Evaluation criteria or scoring matrices
- Domain-specific frontmatter fields for wiki pages

### Phase 3 — Sources & Import Procedures

Ask the user:
- "What kinds of sources will you feed into this KB?"
- For each source type: "What should be extracted? What signals matter?"
- "How should sources connect to existing knowledge?"

Extract:
- One import procedure definition per source type
- Extraction rules per procedure
- Connection rules per procedure

Each import procedure becomes a file in `imports/`. Use the template from `assets/templates/import-procedure.md`.

### Phase 4 — Structure & Preferences

Ask the user:
- "Do you want additional wiki subdirectories beyond entities/concepts/synthesis?"
- "What tone should the wiki pages have?" (analytical, narrative, terse, etc.)
- "Any naming conventions for pages?"

Extract:
- Additional wiki folder names
- Style guide preferences
- The KB name (used for the qmd collection and directory name)

### Phase 5 — Scaffold

Once all phases are confirmed, generate the knowledge base. Load `references/creation-guide.md` for detailed scaffolding instructions and templates.

**Scaffolding steps:**

1. Create the directory structure:
   ```
   <kb-name>/
   ├── CONSTITUTION.md
   ├── LOG.md
   ├── imports/
   │   ├── _template.md
   │   └── [user-defined procedures].md
   ├── raw/
   │   └── [organized by import type]
   ├── wiki/
   │   ├── entities/
   │   ├── concepts/
   │   ├── synthesis/
   │   ├── [<procedure-name>/ for each import procedure]
   │   └── [domain-specific folders]
   └── .kb/
       └── config.md
   ```

   For each import procedure defined in Phase 3, create a corresponding `wiki/<procedure-name>/` folder. These hold source summary pages created during imports (e.g. `wiki/research-papers/`, `wiki/meeting-notes/`).

2. Generate **CONSTITUTION.md** from all extracted answers (use template from `assets/templates/constitution.md`)
3. Generate **import procedure files** in `imports/` (use template from `assets/templates/import-procedure.md`)
4. Initialize **LOG.md** with the creation entry (use template from `assets/templates/log.md`)
5. Write **.kb/config.md** with the collection name, absolute path, and settings

6. **Register the KB.** Append an entry to `.kb/registry.md` (in the agent's root working directory):
   - If `.kb/registry.md` does not exist, create it with:
     ```markdown
     # Knowledge Base Registry

     | Name | Path | Created |
     |------|------|---------|
     ```
   - Append a row: `| <kb-name> | <absolute-path-to-kb> | <YYYY-MM-DD> |`
   - The path MUST be absolute (not relative)

7. Configure qmd:
   ```bash
   qmd collection add ./wiki/ --name "<kb-name>" --mask "**/*.md"
   qmd context add qmd://<kb-name> "<domain description from CONSTITUTION>"
   qmd update --collections <kb-name>
   qmd embed
   ```

8. Log the creation event to LOG.md (insert below header, above existing entries)

9. Report what was created and suggest next steps (importing first sources via `kb-import`).

## Output

After scaffolding, display:
- Summary of what was created
- The CONSTITUTION highlights
- List of import procedures defined
- qmd collection name and status
- Suggested next step: "Drop a source file into `raw/` and run kb-import to start building your wiki."
