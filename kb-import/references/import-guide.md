# Import Guide — Detailed Reference

## How Import Procedures Work

An import procedure is a prompt template saved as markdown in the `imports/` directory. It tells the LLM exactly how to process a specific type of source.

Each procedure file has:
- **YAML frontmatter**: `name`, `trigger` (when to use this procedure), `source_destination` (where to file the raw source)
- **Extraction Steps**: What to look for in the source
- **Wiki Updates**: What pages to create or update
- **Cross-Linking Rules**: How new content connects to existing pages
- **Quality Check**: Validation rules to apply after import

## Selecting the Right Procedure

When a user provides a source:

1. Read all files in `imports/` (except `_template.md`)
2. For each procedure, check if the source matches its `trigger` description
3. Consider:
   - File type (PDF → likely a paper or document procedure)
   - Content type (if you can read it, what kind of content is it?)
   - User's explicit instruction ("import this as a research paper")
4. If ambiguous, ask the user

## Processing Strategy

### For a NEW source type (no matching procedure)

Two options:
1. **One-off import**: Use the CONSTITUTION's general extraction rules. Good for occasional sources that don't warrant their own procedure.
2. **Create a new procedure**: Guide the user through defining one (via kb-evolve). Better for source types they'll see repeatedly.

### For LARGE sources (books, long reports)

- Process in chapters or sections
- Create a source summary page that links to all extracted content
- Don't try to extract everything in one pass — prioritize what the CONSTITUTION says matters most

### For CONFLICTING information

When new source contradicts existing wiki content:
- Do NOT silently overwrite
- Add the new perspective alongside the existing one
- Flag the contradiction explicitly: "**Contradiction**: [[Source A]] claims X, while [[Source B]] claims Y"
- If possible, create or update a synthesis page that analyzes the conflict

### For UPDATE sources (new version of something already imported)

- Find the existing source summary page
- Update it with changes
- Propagate updates to entity and concept pages
- Note what changed in the LOG entry

## Back-Link Pass in Detail

The back-link pass ensures new pages don't become orphans. After creating pages:

1. **Forward links**: The new page already links to existing pages (you added those during creation). These are easy.

2. **Backward links**: Existing pages should link TO the new page where relevant. To find candidates:
   - Search for the new page's key terms across the wiki using qmd
   - Read candidate pages and add `[[wikilinks]]` where the connection is meaningful
   - Don't force connections — only link where there's a genuine relationship

3. **Minimum threshold**: Every new page should have at least 2 inbound links. If you can't find 2 natural connections, the page might be too granular or the KB might need more content first.

## Quality Checklist (after every import)

- [ ] All new pages have YAML frontmatter with correct `type`, `created`, `sources`
- [ ] All new pages have a `## Related` section with at least 2 `[[wikilinks]]`
- [ ] All new pages are listed in INDEX.md
- [ ] Existing pages that should reference new content have been updated
- [ ] LOG.md has a prepended entry for this import
- [ ] No `[[wikilinks]]` point to nonexistent pages (unless intentional stubs)
- [ ] `qmd update && qmd embed` has been run
- [ ] Contradictions (if any) are flagged, not silently resolved
