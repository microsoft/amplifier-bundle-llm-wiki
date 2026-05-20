# Architecture

> Bundle: `amplifier-bundle-llm-wiki`
> Status: 0.1.0 scaffold; modes not yet authored
> Last updated: 2026-05-20

## Purpose

Bring the [Karpathy LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) into Amplifier as a composable mode bundle.

The pattern in one paragraph: instead of having an LLM rediscover knowledge from scratch on every query (RAG), have it incrementally build and maintain a persistent, cross-referenced markdown knowledge base from raw inputs. The wiki is the compiled artifact. The LLM owns the bookkeeping. Humans curate, ask questions, and review.

## Design choices

### 1. Five workflow modes, not slash commands

Amplifier's mode mechanism (via `amplifier-bundle-modes`) gives us:

- **Tool policy enforcement** — each mode declares what tools are safe/warn/confirm/block
- **Lazy context loading** — mode bodies are injected only when the relevant mode is active; zero token cost when inactive (v0.1.0 carries operational guidance in mode bodies; `contributes.context` for separately-managed reference files is planned for v0.2)
- **Specialist agent + skill contribution** — modes can lazily mount agents and skills, removed on deactivation
- **Allowed transitions** — modes can declare valid follow-on modes, enabling guided workflows

These properties don't exist in raw slash commands. Adopting them is the central reason this is a bundle of modes rather than four shell scripts.

### 2. Mechanism vs policy split

The bundle ships **generic mechanism** that knows nothing about any specific knowledge domain. Each project supplies its own **policy** for the parts the bundle deliberately leaves abstract.

| Bundle ships (mechanism) | Project supplies (policy) |
|---|---|
| Mode bodies with generic procedures | Schema definition (entity types, JSON shape, frontmatter conventions) |
| Contributed context describing the pattern | Publish target + script (`.wiki/scripts/publish.sh`) |
| Reference scripts at known paths | Optional viewer / static site |
| Skill + agent for designing the policy | Optional mode overrides in `.amplifier/modes/` |

This is the "mechanism, not policy" principle that runs through Linux, Amplifier core, and most well-designed extensibility systems.

### 3. The five modes

| Mode | Type | Tool policy posture | Contributes | Exit |
|---|---|---|---|---|
| `wiki-init` | Workflow (1-time per project) | safe: read/grep, delegate, todo; confirm: write/edit; block: bash | `wiki-policy-designer` agent + policy-design context | `/mode off` after scaffold complete |
| `wiki-ingest` | Workflow | safe: read/grep, write/edit (review via git diff, not per-call), bash, delegate, todo; default_action: block | Procedure context + schema-reference context | `/mode off` after commit; transition to `/wiki-lint` natural follow-on |
| `wiki-lint` | Read-only constraint | safe: read/grep, bash, todo; default_action: block | Lint-rules context + schema-reference context | `/mode off` if clean; transition to `/wiki-ingest` to fix |
| `wiki-publish` | High-stakes workflow | safe: read/grep, bash (calls publish.sh), todo; default_action: block; allowed_transitions: [wiki-lint] | Publish-procedure context | `/mode off` after successful publish |
| `wiki-query` | Read-only analyst | safe: read/grep, load_skill, todo; default_action: block | Query-procedure context + schema-reference context | `/mode off` or `/wiki-ingest` to file the answer |

### Mode YAML fields beyond tool policy

All five modes use:
- `default_action: block`
- `allow_clear: true`

Mode-specific `allowed_transitions`:
- `wiki-ingest`: `[wiki-lint]`
- `wiki-lint`: `[wiki-ingest]`
- `wiki-publish`: `[wiki-lint]`
- `wiki-query`: `[wiki-ingest]`
- `wiki-init`: none (free to exit anywhere after init)

### 4. Why writes are `warn` (not `confirm`) in `wiki-ingest`

A single ingest cycle touches 10-15 files. `confirm` is per-call — 15 prompts is hostile UX. `safe` is silent, which loses the moment-of-intent at the start of bulk writes. `warn` is the right middle ground: the first `write_file` call is blocked with a hint to narrate intent; after the LLM explains what it's about to do, subsequent writes proceed silently. The actual review gate is the **git diff at commit time** plus the local viewer refresh — that's the human checkpoint.

### Minimal mode file structure

For reference, every mode file follows this YAML frontmatter + markdown body shape:

```markdown
---
mode:
  name: wiki-ingest
  description: One-line purpose
  shortcut: wiki-ingest
  advertised: true
  default_action: block
  allow_clear: true
  allowed_transitions: [wiki-lint]

  tools:
    safe: [read_file, glob, grep, bash, delegate, load_skill, todo, mode]
    warn: [write_file, edit_file]

  contributes:
    # agents, context, skills — empty for v0.1.0
---

# Wiki Ingest Mode

[Body: purpose, workflow, discipline, exit guidance]
```

`name`, `description`, `default_action`, and `tools.*` are required. Everything else has defaults documented in the `amplifier-bundle-modes` schema reference.

### 5. Why `wiki-query` is read-only

Two write paths is one too many. If a query produces a synthesis worth keeping, transition to `/wiki-ingest` to file it as a page. Single write path; clear audit trail (every `git log --grep ingest`).

### 6. Why `wiki-init` is its own mode

A new project adopting this bundle has dozens of decisions to make (schema, entity types, publish target, viewer choice, scrub rules). Without a guided workflow, adopters either skip them and run on defaults that don't fit their domain, or fork the bundle and contaminate it with their specifics.

`/wiki-init` is the meta-mode (analogous to `/mode-design` in `amplifier-bundle-modes`). It contributes a `wiki-policy-designer` agent that drafts the project-side files from the user's choices. Activate once per project, exit when done.

## Extension points

A project that includes this bundle can extend at these well-defined points:

| Point | Mechanism | Example |
|---|---|---|
| Schema | Project supplies `.wiki/context/schema.md` referenced by modes | Team-pulse: JSON-with-narrative-docs hybrid; `sources[]` cross-refs |
| Publish | Project supplies `.wiki/scripts/publish.sh` invoked by `/wiki-publish` | Team-pulse: regenerate two zips for handoff |
| Verify | Project supplies `.wiki/scripts/verify-ext.sh` (optional) called after generic `verify.sh` | Team-pulse: JSON parse + cross-ref integrity |
| Mode override | Project drops `.amplifier/modes/<name>.md` with same `name:` to fully replace a bundle mode | Rarely needed; prefer schema + scripts |
| Project context | Project AGENTS.md, optionally additional `.wiki/context/*.md` | Team-pulse: workspace conventions, pod taxonomy |

The bundle never reads project-specific information directly. It reads its own context files (which describe the *pattern*) and shells out to scripts at known paths.

### Path stability

The `.wiki/context/schema.md` and `.wiki/scripts/*.sh` paths are a **public interface** between the bundle and adopting projects. Breaking changes to these paths are treated as semver-major bundle changes.

### Why `.wiki/` and not `.amplifier/`

`.amplifier/` is for Amplifier infrastructure (settings, sessions, modes); `.wiki/` is project-domain policy data. Separating them keeps Amplifier's runtime concerns distinct from the project's content concerns.

### Token cost target

Mode bodies should aim for **<800 tokens each** at v0.1.0. Once a mode body exceeds that, extract operational reference into `context/<name>-reference.md` and reference via `contributes.context` (planned for v0.2).

## Composition

```
project's .amplifier/settings.yaml
        │
        ├── includes: amplifier-bundle-llm-wiki    ← this
        │       └── includes: amplifier-bundle-modes
        │              └── includes: amplifier-foundation
        │
        └── .amplifier/modes/  (project-local, beats bundle modes by precedence)
                ├── (optional) wiki-publish.md  ← project override by `name:` match
                └── (optional) other custom modes
```

Discovery rule: project `.amplifier/modes/` beats user `~/.amplifier/modes/` beats bundle `modes/`. First-match wins by `name:`.

## Mode handoff pattern

Typical adoption arc:

```
new project
    │
    /wiki-init   ──── walks through schema, publish, viewer; scaffolds .wiki/
    │  /mode off
    │
    (transcripts/content arrive in raw/)
    │
    /wiki-ingest ──── processes raw → wiki; touches 10-15 files; reviewed via git diff
    │  /mode off
    │  git commit
    │  /wiki-lint ──── (optional but recommended)
    │      /mode off if clean
    │      /wiki-ingest to fix if not
    │
    /wiki-publish ── generates artifact via project's publish.sh
    │  /mode off
    │
    ... cycle ...
    │
    (someone asks a question)
    │
    /wiki-query   ── reads index-first, drills relevant pages, synthesizes with citations
    │  /mode off if ephemeral
    │  /wiki-ingest to file the answer
```
## `.wiki/` path resolution

Mode bodies instruct the LLM to read project files at conventional paths:

- `read_file(".wiki/context/schema.md")` — load the project's schema into working memory at the start of ingest or query operations
- `bash(".wiki/scripts/publish.sh")` — invoked by `/wiki-publish`
- `bash(".wiki/scripts/verify.sh")` — invoked by `/wiki-lint` if it exists; falls back to bundle-generic checks if absent
- `bash(".wiki/scripts/freshness.sh")` — invoked by `/wiki-lint` if it exists

Mode bodies should narrate this expectation and fail with a clear message if `.wiki/context/schema.md` is missing (project not initialized — suggest `/wiki-init`).

## `wiki-policy-designer` agent

`/wiki-init` contributes the `wiki-policy-designer` agent, which drafts project-side scaffold files from policy decisions surfaced during the init conversation. See `agents/wiki-policy-designer.md` for the agent's tool set and output contract.

## Mode override semantics

Project modes in `.amplifier/modes/` override bundle modes by `name:` match in YAML frontmatter — **not** by filename. A project could create `my-custom.md` with `name: wiki-ingest` and it would shadow the bundle's `wiki-ingest` mode. Filename is purely organizational; `name:` is load-bearing.


## Failure modes we accept

1. **No automatic review gate.** Projects supply their own review discipline (git diff at commit time, viewer refresh). The bundle does not force a staging branch or per-write confirmation. Projects needing stricter gating layer it via project-local mode overrides.

2. **First-match-wins mode discovery.** A project mode silently replaces a bundle mode with the same name. We accept this in exchange for not building an inheritance hierarchy. Bundle modes have stable, well-documented names so project authors know what they're overriding.

3. **No schema enforcement.** The bundle assumes the project's schema is internally consistent. Lint mode checks consistency *against the project-supplied schema reference*, but doesn't validate the schema itself.

## Open questions

- **Should `wiki-init` ship a default project scaffold?** Tension: pre-filled defaults make adoption faster but encourage projects to skip thinking about their own schema. Current plan: ship a minimal default with loud "REVIEW THIS BEFORE INGESTING" comments.

- **Should the bundle provide an `examples/minimal-wiki/` template?** Probably yes, for adopters who learn by reading working examples. Pending mode authoring.

- **How do we version mode behavior changes?** Modes are markdown files; semver applies to the bundle as a whole but individual mode bodies don't carry version numbers. Major behavior changes go in CHANGELOG with explicit migration notes.
