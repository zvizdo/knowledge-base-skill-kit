# Creation Guide — Detailed Reference

This document provides deep guidance for the kb-create scaffolding process. Load this during Phase 5.

## Conversational Style

The creation wizard is NOT a form. It is a conversation.

- Ask one question at a time (or a small related cluster)
- Listen to the answer and probe deeper if it's vague
- Reflect back what you understood: "So it sounds like you want..."
- Get explicit confirmation before moving on
- If the user is unsure, offer examples from common KB patterns
- Adapt the depth of questioning to the user's engagement — some users want to think deeply about every detail, others want sensible defaults

## Phase-by-Phase Guidance

### Phase 1 — Purpose & Domain

The goal is to understand WHY this KB exists. The purpose statement should be specific enough that it can guide future decisions about what to include and what to exclude.

Good purpose: "Track and synthesize research on attachment theory and its practical implications for romantic relationships"
Bad purpose: "Store notes about psychology"

The north star question should be something the KB gets better at answering over time:
- "What predicts long-term relationship compatibility?"
- "How do different training methodologies affect endurance performance?"
- "What patterns distinguish successful startups from failures?"

### Phase 2 — Entities & Concepts

**Entities** are concrete things that get their own page: people, papers, companies, events, products, etc. Each entity type should have:
- A clear definition of what qualifies
- Suggested frontmatter fields (beyond the standard set)
- What should appear on every entity page

**Concepts** are frameworks, theories, models, or abstract ideas. They serve as lenses for analyzing entities. Examples:
- In a research KB: "Attachment Theory", "Big Five Personality Model"
- In a startup KB: "Product-Market Fit", "Network Effects"
- In a sports KB: "Periodization", "VO2 Max Training"

**Evaluation criteria** are optional but powerful. If the domain involves comparing or rating things, define the criteria up front:
- What dimensions matter?
- What scale? (1-5? qualitative tiers?)
- Are there weighted composites?

### Phase 3 — Sources & Import Procedures

Each source type needs a well-defined import procedure. Guide the user through:

1. **Name the source type**: "research-paper", "interview-notes", "match-profile", "book-chapter"
2. **Define extraction**: What entities to look for? What concepts to apply? What data points matter?
3. **Define connection rules**: How should new content link to existing wiki pages?
4. **Define quality checks**: Minimum link count? Required sections? Cross-reference rules?

Create one `imports/<name>.md` file per source type using the import procedure template.

Also create `raw/` subdirectories for each source type (e.g., `raw/research/`, `raw/interviews/`).

Create a corresponding `wiki/<procedure-name>/` folder for each import procedure (e.g., `wiki/research-papers/`, `wiki/interviews/`). These hold the source summary pages that kb-import creates during each import.

### Phase 4 — Structure & Preferences

Standard wiki subdirectories are always created:
- `wiki/entities/` — atomic pages for concrete things
- `wiki/concepts/` — framework and theory pages
- `wiki/synthesis/` — cached inferences capturing derived relationships, patterns, and comparisons across entities and concepts. Created by kb-query (filing query answers) and kb-maintain (synthesis opportunities). Reading one synthesis page replaces traversing the 5-10 pages it draws from.
- `wiki/<procedure-name>/` — one per import procedure, holds source summary pages

The user may want additional directories for domain-specific categories. Examples:
- `wiki/timelines/` for chronological analyses
- `wiki/comparisons/` for structured comparisons
- `wiki/methodologies/` for procedural knowledge

**Tone options** to suggest:
- Analytical (default) — factual, structured, evidence-focused
- Narrative — story-driven, contextual
- Terse — bullet points, minimal prose
- Academic — formal, citation-heavy

**KB name** should be:
- Lowercase, hyphenated (e.g., `research-kb`, `dating-kb`, `startup-analysis`)
- Used as the directory name AND the qmd collection name

### Phase 5 — Scaffold

After confirming everything, generate all files. Use the templates in `templates/` as starting points, filling in the user's specific answers.

**CONSTITUTION.md generation:**
- Purpose section from Phase 1
- Domain section from Phase 1
- Core entities section from Phase 2 (with frontmatter definitions)
- Core concepts section from Phase 2
- Extraction rules compiled from Phase 3 procedures
- Connection rules compiled from Phase 3
- Evaluation criteria from Phase 2 (if applicable)
- Tone and style from Phase 4

**qmd setup sequence** (must run in this order):
```bash
# 1. Create collection scoped to wiki directory
qmd collection add ./wiki/ --name "<kb-name>" --mask "**/*.md"

# 2. Add context describing the KB domain
qmd context add qmd://<kb-name> "<domain description>"

# 3. Index the (empty) collection
qmd update --collections <kb-name>

# 4. Generate embeddings
qmd embed
```

If `qmd` is not installed, stop and guide the user:
```bash
bun install -g @tobilu/qmd
```

Also check for the qmd agent skill. If not installed, point the user to:
- https://github.com/levineam/qmd-skill

**Register the KB:**

After scaffolding, append an entry to `.kb/registry.md` in the agent's root working directory:

```markdown
# Knowledge Base Registry

| Name | Path | Created |
|------|------|---------|
| research-kb | /Users/alice/knowledge-bases/research-kb | 2026-03-15 |
```

- If `.kb/registry.md` doesn't exist, create it with the header row first
- The path MUST be absolute
- This registry is how all other skills (kb-import, kb-query, kb-maintain, kb-evolve) find the KB

**Verify after scaffold:**
- All directories exist
- CONSTITUTION.md is written and accurate
- All import procedures are in `imports/`
- LOG.md is initialized
- qmd collection is created and indexed
- `.kb/config.md` has the collection name and absolute path
- `.kb/registry.md` has an entry for this KB

## Common KB Patterns

If the user is unsure what they want, offer these patterns as inspiration:

**Research KB**: Track papers, extract findings, build concept pages around theories, synthesize across studies. Entity types: papers, researchers, institutions. Concepts: methodologies, theoretical frameworks.

**People/Relationship KB**: Profile people, track interactions, analyze compatibility. Entity types: people, events. Concepts: personality frameworks, communication styles, compatibility models.

**Domain Expertise KB**: Accumulate knowledge in a professional field. Entity types: tools, techniques, case studies. Concepts: best practices, anti-patterns, decision frameworks.

**Learning KB**: Track what you're learning across courses, books, conversations. Entity types: sources, authors, key ideas. Concepts: mental models, skill progressions.
