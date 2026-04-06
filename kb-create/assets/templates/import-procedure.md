---
name: {{PROCEDURE_NAME}}
trigger: "{{TRIGGER_DESCRIPTION}}"
source_destination: raw/{{SOURCE_SUBDIR}}/
---

# {{PROCEDURE_TITLE}} Import

## Extraction Steps

1. Read the source document
2. Identify: {{EXTRACTION_TARGETS}}
3. Extract entities: {{ENTITY_TYPES_TO_EXTRACT}}
4. Extract concepts: {{CONCEPT_TYPES_TO_EXTRACT}}

## Wiki Updates

- Create or update entity pages in `wiki/entities/`
- Create or update concept pages in `wiki/concepts/`
- Add `[[wikilinks]]` to all related existing pages (back-link pass)
- Update `wiki/synthesis/` pages if new findings contradict or strengthen existing analysis

## Cross-Linking Rules

- Every new entity page MUST link to at least one concept page
- Every new concept page MUST link to related entities
- Flag contradictions with existing pages explicitly
- {{ADDITIONAL_LINKING_RULES}}

## Index & Log

- Update INDEX.md with new/modified pages
- Prepend entry to LOG.md

## Quality Check

- Verify all new pages have at least 2 inbound `[[wikilinks]]`
- Verify no orphan pages were created
- Run `qmd update --collections {{KB_NAME}} && qmd embed`
