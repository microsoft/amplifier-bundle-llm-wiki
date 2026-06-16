---
mode:
  name: wiki-publish
  description: Generate the shippable artifact via the project's publish script
  shortcut: wiki-publish
  advertised: true
  default_action: block
  allow_clear: true
  allowed_transitions:
    - wiki-lint

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
      - "@llm-wiki:docs/llm-wiki-pattern.md"
---

# Wiki Publish Mode

You are generating the shippable artifact via the project's `.wiki/scripts/publish.sh`. **High stakes**: the output is what downstream consumers see. Rollback is the project's responsibility.

**Output target**: `.wiki/dist/` by convention. The script writes its zip + manifest there. `.wiki/dist/` is gitignored.

**Wiki orientation auto-injected:** `@llm-wiki:context/wiki-instructions.md` is prepended to this mode's context — it describes the cross-mode workflow and the three-zone structure.

## Workflow

### Step 1 — Pre-flight

```bash
test -x .wiki/scripts/publish.sh || {
  echo "missing publish script — run /wiki-init or write .wiki/scripts/publish.sh"
  exit 1
}
git status --short
```

If git status shows uncommitted changes in the wiki, surface them. The user decides whether to commit first or publish dirty.

### Step 2 — Recommend lint

If `/wiki-lint` hasn't been run in this session, suggest transitioning there first. Don't force it; the user may have already verified.

### Step 3 — Invoke publish

```bash
.wiki/scripts/publish.sh
```

Report the script's output verbatim. If it produces artifacts (zip files, build dirs), list them with sizes.

### Step 4 — Verify

After publish:

- If the script writes to `.wiki/dist/` (the conventional local target), list what's there now (`ls -la .wiki/dist/`).
- If the script writes externally (push to a remote, HTTP POST, S3 sync), confirm the script reported success.
- Run `.wiki/scripts/verify-published.sh` if it exists.

### Step 5 — Exit

- **Success**: `/mode off`
- **Failure**: transition to `/wiki-lint` to diagnose, or `/mode off` to debug manually

## Discipline

- **Trust the project's publish script.** It encodes the project's policy. Don't second-guess what it does.
- **Don't modify wiki content from this mode.** Writes are blocked. If the artifact is broken at the source, exit, use `/wiki-ingest` to fix, return.
- **Report what shipped.** Always. The user needs to know what went out.

## Exit

`/mode off` after a successful publish; transition to `/wiki-lint` if something looks wrong.
