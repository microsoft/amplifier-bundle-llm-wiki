# amplifier-bundle-llm-wiki

Generic Amplifier mode bundle implementing the [Karpathy LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) as composable workflow modes.

## What it is

An LLM Wiki is a persistent, cross-referenced markdown knowledge base that the LLM incrementally builds and maintains from raw source material — instead of re-deriving answers from scratch on every query.

This bundle ships the *mechanism* for the pattern: five workflow modes that wrap its canonical operations.

| Mode | Purpose |
|---|---|
| `/wiki-init` | Design and scaffold the project-specific policy (schema, publish target, viewer) |
| `/wiki-ingest` | Process raw content from `raw/` into the wiki |
| `/wiki-lint` | Read-only health check — orphans, stale refs, contradictions, broken cross-refs |
| `/wiki-publish` | Generate the shippable artifact via the project's publish script |
| `/wiki-query` | Read-only Q&A against the compiled wiki |

The bundle does NOT ship policy: schema, entity vocabulary, publish target, viewer. Those are project-supplied via `.wiki/` (context files + scripts) and optional project-local mode overrides in `.amplifier/modes/`.

## Install

In your project's `.amplifier/settings.yaml`:

```yaml
includes:
  - bundle: git+https://github.com/<owner>/amplifier-bundle-llm-wiki@main
```

Then bootstrap your project:

```
/wiki-init
```

## Architecture

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the full design.

Short version:

- **Mechanism** (this bundle): mode bodies, contributed context, reference scripts at known paths
- **Policy** (your project): schema definition, publish target, viewer, optional mode overrides
- **Discovery**: Amplifier loads bundle modes by default; project modes in `.amplifier/modes/` override silently by name

## Status

`0.1.0` — initial scaffold. Modes pending. Dogfooded against the team-pulse content workflow.

## Lineage

- Andrej Karpathy, [LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) (April 2026) — the original pattern
- [`amplifier-bundle-modes`](https://github.com/microsoft/amplifier-bundle-modes) — provides the mode mechanism this bundle ships modes for
- Reference implementations studied: alirezarezvani/claude-skills, balukosuri/llm-wiki-karpathy, balukosuri/wiki-from-code, lucasastorian/llmwiki, xoai/sage-wiki, tobi/qmd, garrytan/gbrain, NousResearch/hermes-agent

## License

MIT — see [LICENSE](LICENSE).
