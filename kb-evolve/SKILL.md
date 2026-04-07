---
name: kb-evolve
description: Modify the knowledge base structure — add new import procedures, update the CONSTITUTION, restructure wiki folders, merge or split pages, and extend tooling as the domain understanding deepens.
---

# kb-evolve — Evolve the Knowledge Base

Modify the KB's structure, rules, and capabilities as your understanding of the domain grows. The CONSTITUTION is not static — it evolves.

## Prerequisites

### Locate the Knowledge Base

Follow these steps in order to determine which KB to operate on:

1. **User specified a KB by name.** If the user said something like "evolve research-kb", look up that name in `.kb/registry.md` to get the absolute path.
2. **Check the current directory.** If `.kb/config.md` exists in the current working directory, use this directory as the KB root.
3. **Read the registry.** Read `.kb/registry.md`:
   - One KB listed → use it.
   - Multiple KBs listed → list them and ask the user which one.
   - No registry or empty → tell the user to run kb-create first.

Once resolved, set `{KB_ROOT}` to the KB's absolute path, then:
- Read `{KB_ROOT}/.kb/config.md` for KB name and qmd collection
- Read `{KB_ROOT}/CONSTITUTION.md` to understand current state
- Scan existing pages with `glob wiki/**/*.md` and `qmd search` to understand current wiki contents

All paths below are relative to `{KB_ROOT}`.

## Operations

### 1. Add Import Procedure

Create a new import procedure for a source type not yet covered.

**Flow:**
1. Ask the user: "What kind of source is this? What should be extracted?"
2. Walk through the same questions as kb-create Phase 3, but for this one source type
3. Generate a new `{KB_ROOT}/imports/<name>.md` using the import procedure template
4. Create `{KB_ROOT}/raw/<subdir>/` for the source files
5. Create `{KB_ROOT}/wiki/<procedure-name>/` for source summary pages produced by this procedure
6. Log to LOG.md (insert below header, above existing entries)

**Template location:** Load `kb-create/assets/templates/import-procedure.md` for the procedure format.

### 2. Update CONSTITUTION

Revise the governing document as understanding deepens.

**Common updates:**
- Add new entity types discovered through usage
- Add new concept frameworks that emerged from analysis
- Refine extraction rules based on what's actually useful
- Adjust connection rules (e.g., increase minimum link count)
- Update evaluation criteria
- Change tone or style preferences

**Flow:**
1. Read current CONSTITUTION.md
2. Ask what needs to change and why
3. Make the change
4. Review the impact: do existing pages need updating to match new rules?
5. If yes, flag pages for review (don't auto-rewrite existing content)
6. Log to LOG.md (insert below header, above existing entries)

### 3. Restructure Wiki

Move pages, rename directories, reorganize categories.

**Operations:**
- **Add directory**: Create new subdirectories in `{KB_ROOT}/wiki/` for new categories
- **Move pages**: Relocate pages to better-fitting directories
- **Rename pages**: Update the page file name AND all `[[wikilinks]]` that reference it across the entire wiki
- **Merge pages**: Combine two pages into one, consolidating content and redirecting all inbound links
- **Split pages**: Break a large page into sub-pages, updating links accordingly

**Synthesis-aware:** When merging or splitting synthesis pages, update their `derived-from` fields to remain accurate. When deleting or renaming entity/concept pages, check if any synthesis page lists them in `derived-from` and update accordingly.

**After any restructure:**
1. Update all `[[wikilinks]]` across the wiki to reflect changes
2. Log to LOG.md (insert below header, above existing entries)
3. Re-sync qmd:
   ```bash
   qmd update --collections <kb-name>
   qmd embed --force
   ```
   Use `--force` on embed after restructures to rebuild all embeddings.

### 4. Bulk Re-process

Re-run imports on existing sources with updated rules.

**When to use:**
- After a significant CONSTITUTION update that changes what should be extracted
- After adding a new concept framework that should be applied retroactively

**Flow:**
1. Identify which sources need re-processing
2. For each source, re-run the import procedure with the updated CONSTITUTION
3. This may create new pages, update existing ones, or add new connections
4. Run full maintenance after bulk re-processing — pay particular attention to Synthesis Opportunities (Step 7) to identify synthesis pages that are now stale due to re-processed content

### 5. Registry Maintenance

Manage the KB registry at `.kb/registry.md` (in the agent's root directory).

**Operations:**
- **Remove stale entry**: If a KB was deleted from disk, remove its row from the registry
- **Update path**: If a KB was moved, update its path in the registry
- **Rename KB**: Update the name in the registry AND in the KB's `.kb/config.md`

**Detection**: When any skill tries to resolve a KB and finds the path doesn't exist, it should suggest running kb-evolve registry maintenance to clean up.

### 6. Add Custom Scripts

Extend the KB with new analysis or utility scripts.

**Placement:**
- Query scripts → `kb-query/scripts/`
- Maintenance scripts → `kb-maintain/scripts/`

All scripts should:
- Parse `[[wikilinks]]` from markdown files
- Accept the wiki directory as the first argument
- Output human-readable results
- Use no external dependencies beyond Python stdlib

## Safety

- **Never delete content without asking.** Restructuring moves or merges — it doesn't discard.
- **Preserve source attribution.** When merging pages, keep all source references.
- **Back up before major restructures.** Suggest `git commit` before large operations.
- **Verify after changes.** Run kb-maintain after any evolution to catch broken links or orphans.

## LOG Entry

Insert the following into LOG.md **directly below the file's header block** (above all existing entries — the log is reverse-chronological, newest first):
```markdown
## [YYYY-MM-DD HH:MM] evolve | Description of Change

- Operation: add-procedure | update-constitution | restructure | bulk-reprocess | registry-maintenance | add-script
- Details: what changed
- Pages affected: [[Page1]], [[Page2]]
- Reason: why this change was made
```

For detailed guidance, load `references/evolution-guide.md`.
