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
    block:
      - write_file
      - edit_file
      - bash

  contributes:
    context:
      - "@llm-wiki:context/wiki-instructions.md"
    agents:
      wiki-policy-designer:
        source: "@llm-wiki:agents/wiki-policy-designer"
---

# Wiki Init Mode

This mode is for projects newly adopting `amplifier-bundle-llm-wiki`. The mode's job is to **resolve the policy brief and then delegate scaffolding to the `wiki-policy-designer` agent**. The mode itself does not scaffold inline — `write_file` and `edit_file` are blocked at the mode level precisely to enforce this.

## Discipline (load-bearing)

**Scaffolding is ALWAYS delegated.** The `wiki-policy-designer` agent carries the authoritative spec for what to write — including the three-zone layout, the self-sufficient `.amplifier/settings.yaml` shape, the read-before-write discipline, and the universal scaffold file list. If you try to scaffold from inside this mode, `write_file` and `edit_file` will fail. That's the design.

This holds even when the user provides a complete policy brief in their first message. **Do not skip delegation.** Confirm the brief is complete, then delegate to `wiki-policy-designer` in a single shot.

## Capabilities while this mode is active

- **Wiki orientation** (auto-injected) — `@llm-wiki:context/wiki-instructions.md` is prepended to this mode's context. It describes the full wiki workflow shape (other modes, project structure, transitions).
- **Agent `wiki-policy-designer`** (REQUIRED for all scaffolding) — Drafts the project-side scaffold files from a finalized policy brief. The agent's spec is authoritative: it enforces the three-zone layout, scaffolds the self-sufficient `.amplifier/settings.yaml`, applies the read-before-write merge discipline, and produces the universal scaffold (`AGENTS.md`, `README.md`, `.gitignore`, `raw/.gitkeep`, `.amplifier/settings.yaml`, `<package-dir>/README.md`, `.wiki/context/schema.md`, `.wiki/scripts/publish.sh`). Invoke via `delegate(agent="wiki-policy-designer", instruction="<full policy brief>")`.

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

### Phase 4 — Scaffold (REQUIRED delegation, no inline writes)

This phase is non-optional. The mode cannot scaffold files — `write_file` and `edit_file` are blocked at the mode level. Delegate to `wiki-policy-designer` with a complete brief:

```
delegate(
  agent="wiki-policy-designer",
  instruction="""
  Scaffold project at <project root>:
  - domain: <from phase 1>
  - schema_choice: <from phase 2>
  - publish_target: <from phase 3>
  - package_name: <from phase 2>
  - project_root: <absolute path>

  Write the project-side scaffold files per your spec.
  Apply the three-zone convention. Produce a self-sufficient .amplifier/settings.yaml.
  """
)
```

If the user provided a complete brief in their opening message, skip Phases 1–3 and go straight to delegation. Do not improvise the scaffold inline. The agent enforces conventions that are easy to miss when scaffolding by hand (`.amplifier/settings.yaml` shape, three-zone placement, AGENTS.md content, etc.).

After the agent returns, surface its summary to the user. The user reviews the diff and commits.

## Additional discipline

- **Don't fork the bundle to add project specifics.** Use `.wiki/` extension points instead.
- **Don't over-engineer the schema.** Start minimal; grow it as patterns emerge.
- **Don't pre-fill content.** The wiki compounds from real sources, not synthetic seeds.
- **The schema is a living document.** Mark uncertain conventions explicitly so the user knows what to refine after the first ingest.

## When NOT to use this mode

- Project already initialized → go straight to `/wiki-ingest`.
- Overhauling an existing schema → use `/mode-design` to draft project-local mode overrides instead.

## Exit

Use `/mode off` once the scaffold is committed and the user is ready to ingest their first source.
