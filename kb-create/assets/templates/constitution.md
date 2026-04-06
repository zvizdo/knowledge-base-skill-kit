# CONSTITUTION — {{KB_NAME}}

> This document governs the identity, purpose, and rules of this knowledge base. Every import, query, and maintenance operation reads this file first.

## Purpose

{{PURPOSE_STATEMENT}}

## Domain

{{DOMAIN_DESCRIPTION}}

## North Star Question

{{NORTH_STAR_QUESTION}}

## Core Entities

Things that get their own page in `wiki/entities/`.

{{#each ENTITY_TYPES}}
### {{name}}
- **Definition**: {{definition}}
- **Frontmatter fields**: {{frontmatter_fields}}
- **Required sections**: {{required_sections}}
{{/each}}

## Core Concepts & Frameworks

Lenses applied when analyzing sources. Each gets a page in `wiki/concepts/`.

{{#each CONCEPT_TYPES}}
### {{name}}
- **Description**: {{description}}
- **When to apply**: {{when_to_apply}}
{{/each}}

## Extraction Rules

What the LLM should look for in every source:

{{EXTRACTION_RULES}}

## Connection Rules

How entities and concepts should link to each other:

- Every entity page MUST link to at least one concept page
- Every concept page MUST link to related entities that exemplify it
- Synthesis pages link to everything they reference
- Contradictions between pages MUST be flagged explicitly
- {{ADDITIONAL_CONNECTION_RULES}}

## Evaluation Criteria

{{#if EVALUATION_CRITERIA}}
{{EVALUATION_CRITERIA}}
{{else}}
No formal evaluation criteria defined. Add them via kb-evolve if needed.
{{/if}}

## Tone & Style

{{TONE_DESCRIPTION}}

---

*This constitution evolves. Update it via kb-evolve as your understanding of the domain deepens.*
