# Wiki Bundle Instructions

This document is injected as context for any project that includes `amplifier-bundle-llm-wiki`. It tells the project's agent what the bundle provides and how to use it.

## Available modes

- `/wiki-init` — design and scaffold the project-specific policy (run this first when adopting the bundle)
- `/wiki-ingest` — process raw content into the wiki
- `/wiki-lint` — read-only health check
- `/wiki-publish` — generate the shippable artifact (invokes the project's publish script)
- `/wiki-query` — read-only Q&A against the wiki

Use `/mode list` to see them. Use `/mode off` to exit any mode.

## Expected project structure

```
<project-root>/
├── AGENTS.md            # project orientation
├── SCRATCH.md           # working memory (optional)
├── raw/                 # immutable source material — LLM reads; never writes
├── <package-dir>/       # the compiled wiki — LLM writes; you read
├── .wiki/
│   ├── context/         # project-specific context files (schema, etc.)
│   └── scripts/         # project-specific scripts (publish, verify-ext, etc.)
└── .amplifier/
    ├── settings.yaml    # includes this bundle
    └── modes/           # optional project-local mode overrides
```

The `<package-dir>` name is project-specific. Common choices: `wiki/`, `kb/`, `notes/`, or a domain-specific name like `team-pulse-package/`.

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
