---
mode:
  name: wiki-lint
  description: Read-only health check of the LLM Wiki — orphans, stale refs, contradictions, broken cross-refs
  shortcut: wiki-lint
  advertised: true
  default_action: block
  allow_clear: true
  allowed_transitions:
    - wiki-ingest

  tools:
    safe:
      - read_file
      - glob
      - grep
      - bash
      - load_skill
      - todo
      - mode
    block:
      - write_file
      - edit_file

  contributes:
    context:
      - "@llm-wiki:context/wiki-instructions.md"
---

# Wiki Lint Mode

You are running a wiki health check. **Read-only.** This mode reports problems; it does not fix them. To apply fixes, exit and use `/wiki-ingest`.

**Wiki orientation auto-injected:** `@llm-wiki:context/wiki-instructions.md` is prepended to this mode's context — it describes the cross-mode workflow and project structure.

## Workflow

### Step 1 — Mechanical checks

Run the project's verification scripts if they exist:

```bash
[ -x .wiki/scripts/verify.sh ]   && .wiki/scripts/verify.sh
[ -x .wiki/scripts/freshness.sh ] && .wiki/scripts/freshness.sh
```

Capture: parse errors, broken cross-refs, stale source SHAs.

### Step 2 — Structural checks

Walk the wiki package directory. Check for:

- **Orphans** — pages with zero inbound `[[wikilinks]]` or `sources[]` references
- **Broken links** — wikilinks or paths pointing to non-existent pages
- **Missing frontmatter** — pages lacking fields the project's schema requires
- **Duplicate titles** — same `title:` on two pages
- **Log gaps** — no log entry in the last 14 days (or whatever the project schema specifies)

### Step 3 — Semantic checks

Read pages updated in the last cycle. Look for:

- **Contradictions** — page A claims X, page B claims ~X
- **Stale claims** — pages older than 30 days that newer sources may have superseded
- **Concept gaps** — terms mentioned across 3+ pages without their own page
- **Cross-reference gaps** — entities mentioned as plain text without wikilinks

### Step 4 — Report

Produce a structured markdown report:

```
# Wiki lint — <date>
**Total pages:** N  **Last log:** <date>

## Found
- ⚠️ <N> contradictions: <list>
- <N> broken links: <list>
- <N> orphans: <list>
- <N> stale pages: <list>
- <N> concept gaps: <list>

## Suggested actions
1. ...
2. ...
```

Severity order: contradictions and broken links first (urgent); orphans and stale claims last (can wait).

### Step 5 — Exit

- **Clean**: `/mode off`
- **Issues found**: transition to `/wiki-ingest` to apply fixes (writes are blocked here)

## Discipline

- **Report only.** No writes — the tool policy enforces this.
- **Be specific.** "This wiki is messy" is not a finding. "`docs/people/alice.md` has 0 inbound references" is.
- **Severity matters.** Surface contradictions and broken links first.
- **Don't synthesize fixes.** Surface the problems; let `/wiki-ingest` resolve them.

## Exit

`/mode off` if clean; transition to `/wiki-ingest` to fix.
