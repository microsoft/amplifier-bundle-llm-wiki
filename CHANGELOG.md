# Changelog

All notable changes to this bundle will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Index and log are now first-class.** `context/wiki-instructions.md` defines a default contract for the two navigational records — `<package-dir>/index.md` (the catalog, read first by `/wiki-query`) and `log.md` (the greppable append-only timeline) — with a one-sentence `schema.md` override. Restores the backbone the canonical LLM Wiki pattern treats as load-bearing; closes the silent-skip gap that let an adopting project accumulate unnavigable drift.
- **The upstream pattern doc is mounted in every wiki mode.** Each `wiki-*` mode now contributes `docs/llm-wiki-pattern.md` (the vendored Karpathy gist) via `contributes.context`, so the foundational pattern is the lens while a mode is active and unmounts on exit — zero cost when dormant.

### Changed
- `modes/wiki-ingest.md` Step 4: replaces "the bundle does not mandate a file or format" with a requirement to update `index.md` and append to `log.md` every cycle (a project's `schema.md` may override paths/formats).
- `modes/wiki-lint.md`: adds an explicit index-drift check (pages ↔ `index.md`) and ties the log-gap check to the `## [date] op | title` format.
- `modes/wiki-query.md` Step 1: reads `<package-dir>/index.md` by default, per the contract.
- `agents/wiki-policy-designer.md`: scaffolds `index.md` as an empty-but-structured catalog (was "a paragraph") and now scaffolds `log.md` (header + format note, no synthetic entries).

### Fixed
- Removed all hardcoded "Team Pulse" references from the generic bundle (scripts' default `WIKI_DIR`, mode/agent examples, `docs/ARCHITECTURE.md`, and the `bundle.dot`/`bundle.png` diagram), and reconciled version drift so versions live only in the bundle manifests and this changelog.
- Vendored the upstream Karpathy "LLM Wiki" gist verbatim to `docs/llm-wiki-pattern.md` with a provenance header, as the bundle's guiding reference.

## [0.2.0] - 2026-05-25

### Changed
- **Zero-cost-when-dormant refactor.** `behaviors/llm-wiki.yaml` is now an install anchor only — it composes the parent bundle so the `modes/` directory is discovered, and carries no always-on context. Shared orientation (`context/wiki-instructions.md`) moved from always-loaded to per-mode `contributes.context`, so it loads only while a `wiki-*` mode is active. Composing the bundle adds zero tokens to the session context until a wiki mode is activated.
- `modes/wiki-init.md`: delegation to the `wiki-policy-designer` agent is now mandatory — all scaffolding goes through the agent, never inline (mode-level `write_file`/`edit_file` are blocked).

### Added
- `agents/wiki-policy-designer.md`: codified the three-zone layout (repo root / `<package-dir>/` / `.wiki/`) and a self-sufficient `.amplifier/settings.yaml` scaffold using the `active`/`added`/`app` shape (not `includes:`), so an adopting project works on a fresh clone with no manual `amplifier bundle` commands.

## [0.1.1] - 2026-05-23

### Changed
- `modes/wiki-ingest.md` Step 5 (Verify): now a mandatory gate. Prefers `.wiki/scripts/publish.sh` (where most projects embed validation) over the optional `verify.sh`. **Both errors and warnings block commit** — warnings represent unfinished work, not advisory chatter. Names the Step-5→Step-3 fix loop as the canonical Triple-Pass discipline (Writer → Evaluator → Editor).
- `modes/wiki-ingest.md` Step 7 (Exit): adds explicit lint-cadence guidance. If ~10 cycles have accumulated since the last `/wiki-lint` pass (check `log.md`), transition to `/wiki-lint` before exit. Lint is part of the canonical 8-stage pipeline's invariant core, not an exit option.

### Why
Empirical evidence from a real adopting project (medium-wiki) showed the prior body permitted 91 bidirectional-sourcing warnings to accumulate silently across 91 ingest cycles. Cross-reference with the canonical LLM Wiki pattern (documented across 9 corpus sources) confirmed three structural mis-ports: (1) Triple-pass loop collapsed to single-pass, (2) verification optional and warnings advisory, (3) lint cadence absent. This release closes mis-ports (2) and (3) directly; mis-port (1) is closed implicitly by the Step-5→Step-3 fix loop. See the adopting project's synthesis page (`wiki/syntheses/wiki-ingest-mode-vs-canonical-pattern.md`) for the full analysis.

### Not changed
- Tool policy on `modes/wiki-ingest.md` (unchanged — `warn` on writes is correct).
- `modes/wiki-init.md`, `modes/wiki-lint.md`, `modes/wiki-publish.md`, `modes/wiki-query.md` (untouched).
- `agents/wiki-policy-designer.md` (scaffold behavior unchanged — `verify.sh` remains optional because Step 5 now prefers `publish.sh`).
- Reference scripts in `scripts/` (unchanged).

## [0.1.0] - 2026-05-20

### Added
- Initial bundle scaffold (directories, README, AGENTS.md, bundle.md)
- Architecture documentation (docs/ARCHITECTURE.md)
- MIT license, contribution conventions
