---
mode:
  name: wiki-query
  description: Read-only Q&A against the LLM Wiki — index-first, drill, synthesize with citations
  shortcut: wiki-query
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
      - load_skill
      - todo
      - mode
    block:
      - write_file
      - edit_file
      - bash

  contributes:
    context:
      - "@llm-wiki:context/wiki-instructions.md"
---

# Wiki Query Mode

You are answering a question against the wiki. **Read-only.** No writes. If the answer is worth keeping, transition to `/wiki-ingest` to file it.

**Wiki orientation auto-injected:** `@llm-wiki:context/wiki-instructions.md` is prepended to this mode's context — it describes the cross-mode workflow and project structure.

## Workflow

### Step 1 — Read the index first

Check `.wiki/context/schema.md` for the project's index location (typically `index.md` at the package root, or a structured manifest). Read it. Identify the 3–10 most relevant pages.

### Step 2 — Drill

Read the relevant pages. Follow `[[wikilinks]]` and `sources[]` cross-refs as needed.

Do **not** read raw sources in `raw/archive/` unless absolutely necessary — those are pre-summarized in the wiki. Respect the compilation.

### Step 3 — Synthesize

Produce the answer with citations. Every claim should reference the wiki page it came from. Use whichever citation style the project's schema specifies:

- `[[wikilink]]` style: "Per [[concepts/x]], the system ..."
- `path:line` style: "(`team-pulse-package/data/projects/auth.json:42`)"

### Step 4 — Offer to file the answer

If the synthesis is non-trivial and worth preserving:

> "This is worth keeping. Want me to transition to `/wiki-ingest` and file it as a synthesis page?"

Let the user choose. Don't auto-file.

### Step 5 — Exit

- **Ephemeral question**: `/mode off`
- **Worth filing**: `/wiki-ingest` to save the synthesis

## Discipline

- **Index first.** Don't grep the whole wiki — the index exists for a reason.
- **Cite every claim.** No exceptions.
- **Don't synthesize beyond evidence.** If the wiki doesn't answer the question, say so. Suggest what to add (sources to ingest, concepts to develop) to make it answerable.
- **Don't write.** Writes are blocked. Use `/wiki-ingest` to file an answer.

## Exit

`/mode off` when done; transition to `/wiki-ingest` to file useful syntheses.
