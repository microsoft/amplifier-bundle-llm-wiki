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

The bundle ships as part of `amplifier-foundation`, so the easiest install is the `amplifier-dev` standalone — it pulls in `amplifier-foundation` (which includes this bundle's behavior file) along with everything else needed for a working Amplifier session:

```bash
amplifier bundle add --active git+https://github.com/microsoft/amplifier-foundation@main#subdirectory=bundles/amplifier-dev.yaml
```

The five `/wiki-*` modes are then discoverable via `/modes` immediately. **Zero token cost is added to your session context until you activate one of the wiki modes** — the behavior file is just configuration that wires up structural mode discovery; nothing about wiki is sent to the LLM until you start using it. See the [zero-cost install-anchor pattern](https://github.com/microsoft/amplifier-bundle-modes/blob/main/context/mode-schema-reference.md#14-structural-discovery-how-modes-gets-scanned) documented in `amplifier-bundle-modes`.

If you'd rather not use the `amplifier-dev` standalone and just want the wiki bundle layered onto an existing base setup, install the behavior file as an app overlay (your active base bundle must include mode infrastructure):

```bash
amplifier bundle add --app git+https://github.com/microsoft/amplifier-bundle-llm-wiki@main#subdirectory=behaviors/llm-wiki.yaml
```

Equivalent in `.amplifier/settings.yaml`:

```yaml
app:
  - git+https://github.com/microsoft/amplifier-bundle-llm-wiki@main#subdirectory=behaviors/llm-wiki.yaml
```

Then bootstrap your project:

```
/wiki-init <describe your wiki>
```

> **Pass a request alongside the mode activation.** `/wiki-init` alone just enters the mode — it doesn't do anything until you give it a brief. Either pass a request on the activation line (e.g. `/wiki-init I want to track weekly team meetings and ship a JSON-backed dashboard`) or activate first and follow up with a request in your next message. The same applies to the other `/wiki-*` modes.

`/wiki-init` walks through the policy decisions (schema, publish target, viewer) and scaffolds the project-side files. Subsequent cycles use `/wiki-ingest <source>` → `/wiki-lint` → `/wiki-publish`. See [AGENTS.md](AGENTS.md) for the operational cycle.

## Architecture

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the full design.

Short version:

- **Mechanism** (this bundle): five workflow modes with rich operational guidance loaded only when a mode is active; reference scripts at known paths; one specialist agent (`wiki-policy-designer`) contributed by `/wiki-init`
- **Policy** (your project): schema definition, publish target, viewer, optional mode overrides
- **Discovery**: Bundle modes are available once this bundle is composed; project modes in `.amplifier/modes/` take precedence over bundle modes with the same `name:`

## Status

`0.2.x` — five workflow modes (`wiki-init`, `wiki-ingest`, `wiki-lint`, `wiki-publish`, `wiki-query`) and one contributed agent (`wiki-policy-designer`). Refactored to the zero-cost-when-dormant pattern: bundle composition contributes zero tokens to the session context until a wiki mode is activated.

## Lineage

- Andrej Karpathy, [LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) (April 2026) — the original pattern
- [`amplifier-bundle-modes`](https://github.com/microsoft/amplifier-bundle-modes) — provides the mode mechanism this bundle ships modes for. See [§9.7 "Workflow Modes with Shared Orientation"](https://github.com/microsoft/amplifier-bundle-modes/blob/main/context/mode-schema-reference.md#97-workflow-modes-with-shared-orientation) — this bundle is documented there as the canonical reference implementation
- Reference implementations studied: alirezarezvani/claude-skills, balukosuri/llm-wiki-karpathy, balukosuri/wiki-from-code, lucasastorian/llmwiki, xoai/sage-wiki, tobi/qmd, garrytan/gbrain, NousResearch/hermes-agent

## License

MIT — see [LICENSE](LICENSE).

## Contributing

> [!NOTE]
> This project is not currently accepting external contributions, but we're actively working toward opening this up. We value community input and look forward to collaborating in the future. For now, feel free to fork and experiment!

Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit [Contributor License Agreements](https://cla.opensource.microsoft.com).

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft
trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
