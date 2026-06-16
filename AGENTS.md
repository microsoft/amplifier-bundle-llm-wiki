# AGENTS.md — amplifier-bundle-llm-wiki

> This file orients **bundle maintainers**, not end-users. End-users see [README.md](README.md).

## What this is

A generic Amplifier mode bundle. Ships modes that wrap the Karpathy LLM Wiki pattern. Project-side policy (schema, publish, viewer) lives in projects that *use* this bundle, not here.

## Layout

```
modes/              # the 5 modes — markdown with YAML frontmatter
context/            # context files contributed by modes on activation
scripts/            # reference implementations of project-side scripts
agents/             # specialist agents contributed by modes
examples/           # minimal worked example for new adopters
docs/               # architecture, design decisions, extension points
bundle.md           # bundle metadata + body
```

## Mechanism vs policy

This is the load-bearing design choice. See `docs/ARCHITECTURE.md` for the reasoning.

| Bundle ships (mechanism) | Project supplies (policy) |
|---|---|
| Mode bodies orchestrating generic procedures | `.wiki/context/schema.md` — entity types, JSON shape, frontmatter conventions |
| Contributed context (abstract procedures, schema discipline) | `.wiki/scripts/publish.sh` — project-specific publish step |
| Reference scripts at known paths | Optional project-local mode overrides in `.amplifier/modes/` |

## Authoring new modes

Use `/mode-design` from `amplifier-bundle-modes`. Three phases:

1. **Intent** — 1-2 sentences on trigger, what changes, exit condition
2. **Tool policy + contributions** — safe/warn/confirm/block, contributed agents/context/skills
3. **Body draft** — delegate to `mode-author` agent

Drop the result in `modes/`. Verify it parses by including the bundle in a test project and `/mode list`.

## Dogfooding

The bundle is dogfooded in a separate content-workflow project that adopts it. When iterating:

1. Edit here
2. In `~/dev/wiki/.amplifier/settings.yaml`, include this bundle by **local path** during development:
   ```yaml
   includes:
     - bundle: /path/to/amplifier-bundle-llm-wiki   # use your local clone path
   ```
3. Activate a mode in `~/dev/wiki`, exercise the workflow, observe failures
4. Fix here, re-test there

When the bundle is published to GitHub, switch the include to a `git+https://` URL.

## Validating changes

After editing a mode, verify it parses by activating it in your dogfooding project:

1. Run `/mode list` — your mode should appear (unless `advertised: false`)
2. Activate with `/mode <name>` — if it activates without error, the YAML frontmatter is valid
3. If activation fails, check the mode's `name:` field and YAML syntax

Regenerate bundle docs after structural changes:

```bash
# from the bundle root, via recipes
amplifier run --recipe @foundation:recipes/validate-bundle-repo
```

This regenerates `bundle.dot` / `bundle.png` and validates the bundle structure.

## What to read before editing

- `docs/ARCHITECTURE.md` — bundle design, extension points, mode handoff pattern
- `bundle.md` — bundle metadata + the body injected into project context
- `~/dev/wiki/references/` (the dogfooding repo) — the 9 LLM Wiki implementations + amplifier-bundle-modes, for reference
