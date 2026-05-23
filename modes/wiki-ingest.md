---
mode:
  name: wiki-ingest
  description: Process raw content into the LLM Wiki — mine, integrate, cross-ref, log
  shortcut: wiki-ingest
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
      - delegate
    warn:
      - write_file
      - edit_file
---

# Wiki Ingest Mode

You are processing new raw content from `raw/` into the project's wiki. The procedure below is the generic LLM Wiki ingest pattern; the project's schema (read from `.wiki/context/schema.md`) tells you the specific entity types and conventions to apply.

## Workflow

### Step 1 — Orient

```bash
ls raw/                                # what's the inbox?
cat .wiki/context/schema.md            # what's the project's schema?
cat AGENTS.md                          # project conventions
```

If `.wiki/context/schema.md` is missing, the project isn't initialized. Suggest `/wiki-init` and exit.

### Step 2 — Mine the source

Process one source at a time (don't batch unless they're tiny related fragments of the same conversation).

Delegate to `foundation:explorer` with a tight brief:

```
delegate(
  agent="foundation:explorer",
  instruction="Extract entities, concepts, decisions, and cross-refs from raw/<file>. Return a structured update plan."
)
```

Discuss 3–5 key takeaways with the user before writing. Get a signal on what to emphasize, skip, or flag as uncertain.

### Step 3 — Apply updates

For each entity/concept/decision in the update plan:

- If a page exists in the wiki: edit it to integrate new claims. Cite the source.
- If not: create the page following the project's template (per the schema).
- Update cross-refs: `[[wikilinks]]`, `sources[]` arrays, or both — per the project's convention.

Touch the index and any catalog files the schema names.

### Step 4 — Append to log

One entry per cycle in the project's log file (typically `log.md` at the package root or per-pod):

```
## [YYYY-MM-DD] ingest | <source title>
- pages touched: <list>
- entities created: <list>
- contradictions surfaced: <list, or "none">
```

### Step 5 — Verify (mandatory gate)

Run the project's validation. In order of preference:

```bash
.wiki/scripts/publish.sh       # most projects embed validation here
# fallback if publish.sh is absent:
[ -x .wiki/scripts/verify.sh ] && .wiki/scripts/verify.sh
```

Read the output. **Both errors and warnings block commit.** Warnings represent unfinished work — the wiki's compounding-knowledge guarantee depends on structural consistency, which validation surfaces but the LLM's draft pass may miss.

If warnings or errors are non-zero: return to Step 3 to fix the underlying writes, then re-run Step 5. Iterate until clean. This Step-5 → Step-3 loop is the Triple-Pass discipline (Writer → Evaluator → Editor) that the canonical LLM Wiki pattern names as the invariant core.

If the project's schema explicitly marks a class of warning as advisory, name that class in the log entry (Step 4) with explicit acknowledgment — don't ignore silently.

### Step 6 — Archive the source

```bash
mv raw/<file> raw/archive/
```

So it isn't re-ingested next cycle.

### Step 7 — Exit

Review the git diff. Commit when satisfied.

**Lint cadence**: if the wiki has accumulated ~10 cycles since the last `/wiki-lint` pass (check `log.md` for the most recent `lint` or `lint-fix` entry), transition to `/wiki-lint` now before exiting. The canonical pattern documents lint as part of the invariant core (production-validated 8-stage pipeline: ingestion → entity extraction → drafting → evaluation → editing → **lint → repair** → consolidation) — not an exit option. Roughly every 10 ingests is the practitioner-recommended frequency.

Otherwise: `/mode off`.

## Discipline

- **One source per session if practical.** Batching mixes contexts and obscures which transcript surfaced which decision.
- **Cite every claim.** Each statement in a wiki page should be traceable to a source in `raw/archive/`.
- **Mark uncertainty explicitly.** When a claim is tentative (transcript ambiguity, contested between sources), add `> TODO-VERIFY:` or `> CONTRADICTION:` blocks per the project's convention.
- **The review gate is the git diff.** Don't ask for per-file confirmation. Trust the draft; trust the human at commit time.
- **`warn` on writes.** The first `write_file`/`edit_file` call will be blocked once with a hint to narrate intent — explain what you're about to write, then proceed. Subsequent writes in this cycle are silent.

## Failure modes

- **Schema is missing or wrong.** Exit; run `/wiki-init` or read `.wiki/context/schema.md` to align.
- **Verify script fails.** Don't commit. Fix the wiki content; re-run; commit only when clean.
- **Source is unclear or hostile.** Don't fabricate. Ingest what you can; flag uncertainties; let the human resolve via follow-up.

## Exit

`/mode off` when committed; `/wiki-lint` for a health pass before publish.
