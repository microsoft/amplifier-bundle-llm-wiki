# Wiki Bundle Instructions

A wiki workflow mode is active. This orientation is mounted by every `wiki-*` mode (`contributes.context`) and unmounts when you exit. It describes the cross-mode shape of the bundle so you know what's adjacent to your current mode.

**The foundational pattern doc (`docs/llm-wiki-pattern.md`) is also mounted in every wiki mode** — it describes the LLM Wiki pattern in the abstract and is the lens to read everything below through. It explains the *why*; this orientation and the project's `.wiki/context/schema.md` give the *how*. When the abstract pattern and a project's specifics seem to conflict, the project's schema wins.

## Available modes

- `/wiki-init` — design and scaffold the project-specific policy (run this first when adopting the bundle)
- `/wiki-ingest` — process raw content into the wiki
- `/wiki-lint` — read-only health check
- `/wiki-publish` — generate the shippable artifact (invokes the project's publish script)
- `/wiki-query` — read-only Q&A against the wiki

Use `/mode list` to see them. Use `/mode off` to exit any mode.

## Expected project structure — the three-zone convention

Every adopting project has exactly **three zones**, defined by *what kind of file lives there*:

```
<project-root>/
├── AGENTS.md                 ← root: stable conventions for maintainers and agents
├── README.md                 ← root: repo orientation for someone cloning cold
├── .gitignore                ← root: ignore patterns
├── .amplifier/
│   └── settings.yaml         ← root: self-sufficient bundle config
├── raw/                      ← root: ephemeral inbox (folder committed, contents gitignored)
│   └── .gitkeep
├── <package-dir>/            ← shippable content boundary — THIS is the wiki
│   ├── README.md             (team-facing orientation, the only README that ships)
│   └── ...content...
└── .wiki/                    ← operational scaffolding (NOT in the zip)
    ├── context/
    │   └── schema.md         (machine-oriented schema for ingest agents)
    ├── scripts/
    │   ├── publish.sh        (writes to .wiki/dist/ by convention)
    │   ├── verify.sh         (optional)
    │   └── freshness.sh      (optional)
    └── dist/                 ← zip output (gitignored)

# Projects may add their own files in the appropriate zone:
#   - persistent operating docs (audit logs, policy files) → root, alongside AGENTS.md
#   - transient/generated reports from workflow modes → .wiki/, alongside scripts/ and dist/
#   - schema-defined entity files → <package-dir>/
```

### What goes where (load-bearing principle)

| Zone | Kind of file | In the zip? |
|------|---------|-------------|
| **Repo root** | User-facing persistent files: orientation, conventions, ignore patterns, Amplifier config, and any operating documents the project chooses to keep across sessions (audit logs, policy docs, etc.) | No |
| **`<package-dir>/`** | Shippable content. The wiki itself. | **Yes** |
| **`.wiki/`** | Operational scaffolding + generated/transient artifacts: project-specific context, scripts, zip output, and any review reports or analysis dumps produced by workflow modes | No |

**The rule of thumb**: anything that doesn't go into `<package-dir>/` and isn't a user-facing persistent file goes into `.wiki/`. This keeps the shippable boundary clean and the operational mess in one place. When `/wiki-ingest` (or any other workflow mode) produces a transient artifact — a review report, an analysis output, a diagnostic — write it under `.wiki/`, never at the repo root, never inside `<package-dir>/`.

The `<package-dir>` name is project-specific. Common choices: `wiki/`, `kb/`, `notes/`, or a domain-specific name.

### Persistent vs transient — the placement test

When deciding where a file goes, ask: *who is the audience and how does the file change?*

- **Repo root** — humans read it; persists across sessions; either hand-edited or appended to over time (like an audit log).
- **`<package-dir>/`** — the wiki's audience reads it; ships in the zip.
- **`.wiki/`** — agents and scripts produce it; regenerated, ephemeral, or operationally-needed-but-not-shipped.

## Index & log — the navigational backbone

Two records keep the wiki navigable and auditable. They are the **default contract** every mode relies on. A project's `.wiki/context/schema.md` may override the paths or formats (e.g. a JSON manifest instead of a markdown index) — when it does, the modes follow the schema. Absent an override, these defaults hold:

- **`<package-dir>/index.md`** — the catalog, and the entry point for every query. One line per page, grouped by entity type:
  ```
  ## People
  - [[people/alice]] — VP Eng; owns the platform roadmap
  ## Concepts
  - [[concepts/retry-policy]] — exponential backoff; supersedes the old fixed-delay rule
  ```
  It ships with the wiki (it's navigation for the wiki's audience). `/wiki-ingest` updates it every cycle; `/wiki-query` reads it first.

- **`log.md`** (repo root, not shipped) — an append-only timeline, one line per cycle, with a fixed prefix so it stays greppable (`grep "^## \[" log.md | tail`):
  ```
  ## [2026-06-16] ingest | Q2 planning call — touched 11 pages
  ## [2026-06-16] lint | 0 contradictions, 2 orphans filed
  ```
  Every `/wiki-ingest` appends one entry; `/wiki-lint` reads it to judge cadence.

These are load-bearing, not optional bookkeeping: index-first navigation is what makes query work without embedding-RAG at moderate scale, and the greppable log is what makes lint cadence and provenance checkable. Skipping them doesn't make the wiki simpler — it makes it unnavigable as it grows.

## First-time setup

New project: `/wiki-init` walks through the policy decisions (schema, publish target, viewer) and scaffolds the project-side artifacts.

Existing project: see the project's `AGENTS.md` for the operational cycle. Typical pattern:

```
/wiki-ingest <transcript>     → review diff → commit
/wiki-lint                    → fix issues if any (transition back to /wiki-ingest)
/wiki-publish                 → generates the shippable artifact
/mode off
```

## Mode handoff

Recommended transitions:

- After `/wiki-ingest` → `/wiki-lint` (verify) → `/wiki-publish` (if clean)
- `/wiki-query` answer worth keeping → `/wiki-ingest` to file it as a synthesis page
- Any time → `/mode off` to exit
