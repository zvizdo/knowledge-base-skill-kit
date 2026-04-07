---
name: {{PROCEDURE_NAME}}
trigger: "{{TRIGGER_DESCRIPTION}}"
source_destination: raw/{{SOURCE_SUBDIR}}/
summary_destination: wiki/{{PROCEDURE_NAME}}/
---

# {{PROCEDURE_TITLE}} Import

## Source Summary

Every import creates a summary page in `wiki/{{PROCEDURE_NAME}}/`. The summary should include:
- {{SUMMARY_FOCUS}} (e.g. key findings, main arguments, decisions made)
- Links to the raw source file
- `[[wikilinks]]` to all entities and concepts touched

## Extraction Steps

1. Read the source document
2. Identify: {{EXTRACTION_TARGETS}}
3. Extract entities (concrete things → `wiki/entities/`): {{ENTITY_TYPES_TO_EXTRACT}}
4. Extract concepts (frameworks, theories, models → `wiki/concepts/`): {{CONCEPT_TYPES_TO_EXTRACT}}

## Wiki Updates

- Create the source summary page in `wiki/{{PROCEDURE_NAME}}/`
- Create or update entity pages in `wiki/entities/`
- Create or update concept pages in `wiki/concepts/`
- Add `[[wikilinks]]` to all related existing pages (back-link pass)
- Update `wiki/synthesis/` pages if new findings contradict or strengthen existing analysis

## Cross-Linking Rules

- Every new entity page MUST link to at least one concept page
- Every new concept page MUST link to related entities
- Flag contradictions with existing pages explicitly
- {{ADDITIONAL_LINKING_RULES}}

## Log

- Add entry to LOG.md (insert below header, above existing entries — newest first)

## Quality Check

- Verify all new pages have at least 2 inbound `[[wikilinks]]`
- Verify no orphan pages were created
- Run `qmd update --collections {{KB_NAME}} && qmd embed`
