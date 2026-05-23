# Changelog

All notable changes to this bundle will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
