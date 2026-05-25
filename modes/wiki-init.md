---
mode:
  name: wiki-init
  description: Design and scaffold the project-specific policy for adopting amplifier-bundle-llm-wiki
  shortcut: wiki-init
  advertised: true
  default_action: block
  allow_clear: true

  tools:
    safe:
      - read_file
      - glob
      - grep
      - load_skill
      - todo
      - mode
      - delegate
    warn:
      - write_file
      - edit_file
    block:
      - bash

  contributes:
    context:
      - "@llm-wiki:context/wiki-instructions.md"
    agents:
      wiki-policy-designer:
        source: "@llm-wiki:agents/wiki-policy-designer"
---

# Wiki Init Mode

This mode is for projects newly adopting `amplifier-bundle-llm-wiki`. It walks the user through the policy decisions the bundle deliberately leaves abstract (schema, publish target, viewer), then dispatches the contributed `wiki-policy-designer` agent to draft the project-side scaffold.

## Capabilities while this mode is active

- **Wiki orientation** (auto-injected) — `@llm-wiki:context/wiki-instructions.md` is prepended to this mode's context. It describes the full wiki workflow shape (other modes, project structure, transitions).
- **Agent `wiki-policy-designer`** — Drafts the project-side scaffold files (`AGENTS.md`, `.wiki/context/schema.md`, `.wiki/scripts/publish.sh`, package skeleton, `.amplifier/settings.yaml`) from a finalized policy brief. Invoke via `delegate(agent="wiki-policy-designer", instruction="<full policy brief>")`.

## Workflow

### Phase 1 — Discover the domain

Ask the user, one question at a time (not a flood):

- What's the source material? (transcripts, articles, papers, meeting recordings, emails, code, mixed)
- What's the wiki output for? (handoff to another team, public docs, personal reference, agent API)
- Who's the audience? (humans only, agents only, both)
- What cadence? (event-driven on source arrival, weekly, monthly, ad-hoc)

Three or four answers is enough. Don't interrogate.

### Phase 2 — Design the schema

Walk through these decisions, stating the trade-off for each:

- **Entity types**: what kinds of things does the wiki track? (e.g. people, projects, decisions, concepts, sources)
- **Storage shape**: pure markdown with frontmatter, or hybrid (JSON for structured data + markdown for narrative)
- **Cross-refs**: `[[wikilinks]]`, frontmatter `sources[]` arrays, or both
- **Page templates**: per-entity-type template files, or freeform

### Phase 3 — Design the publish path

- **Publish target**: zip handoff, git push to target repo, HTTP POST, scheduled fetch, S3, GitHub Pages
- **Publish trigger**: manual `/wiki-publish`, post-commit hook, scheduled
- **Format**: raw markdown, processed JSON, packaged zip, build artifacts

### Phase 4 — Scaffold

Hand off to the contributed agent with a complete brief:

```
delegate(
  agent="wiki-policy-designer",
  instruction="""
  Scaffold project at <project root>:
  - domain: <from phase 1>
  - schema choice: <from phase 2>
  - publish target: <from phase 3>
  - package directory name: <from phase 2>

  Write the project-side scaffold files per your spec.
  """
)
```

The agent drafts the files. You confirm each `write_file`/`edit_file` (first prompt only — subsequent writes proceed silently per `warn` policy).

## Discipline

- **Don't fork the bundle to add project specifics.** Use `.wiki/` extension points instead.
- **Don't over-engineer the schema.** Start minimal; grow it as patterns emerge.
- **Don't pre-fill content.** The wiki compounds from real sources, not synthetic seeds.
- **The schema is a living document.** Mark uncertain conventions explicitly so the user knows what to refine after the first ingest.

## When NOT to use this mode

- Project already initialized → go straight to `/wiki-ingest`.
- Overhauling an existing schema → use `/mode-design` to draft project-local mode overrides instead.

## Exit

Use `/mode off` once the scaffold is committed and the user is ready to ingest their first source.
