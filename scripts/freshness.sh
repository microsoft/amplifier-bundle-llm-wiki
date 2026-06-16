#!/usr/bin/env bash
# scripts/freshness.sh — source-staleness check (reference implementation)
#
# Adopting projects copy this to .wiki/scripts/freshness.sh and customize.
#
# This reference impl:
#   - Walks wiki pages with sources[] frontmatter or sources[] in JSON
#   - For each cited file, computes current `git hash-object`
#   - Compares to a stored SHA (project schema must include source SHAs)
#   - Reports drift
#
# Note: SHA tracking requires the project schema to record `sha` alongside
# `path` in sources[]. If not present, this script reports "no SHA tracking".

set -eu

WIKI_DIR="${1:-wiki}"

if [ ! -d "$WIKI_DIR" ]; then
  echo "freshness: directory $WIKI_DIR not found"
  exit 2
fi

if ! command -v jq > /dev/null 2>&1; then
  echo "freshness: jq not available; cannot check sources[]"
  exit 2
fi

DRIFT=0
TRACKED=0

while IFS= read -r f; do
  entries=$(jq -c '.. | objects | select(.sources? != null) | .sources[]? | select(.sha? != null) | {path: .path, sha: .sha}' "$f" 2>/dev/null || true)
  if [ -n "$entries" ]; then
    while IFS= read -r entry; do
      path=$(echo "$entry" | jq -r '.path')
      stored_sha=$(echo "$entry" | jq -r '.sha')
      target="$WIKI_DIR/$path"
      if [ -f "$target" ]; then
        current_sha=$(git hash-object "$target" 2>/dev/null || echo "")
        TRACKED=$((TRACKED + 1))
        if [ "$current_sha" != "$stored_sha" ]; then
          echo "DRIFT: $f cites $path with sha=$stored_sha; current is $current_sha"
          DRIFT=$((DRIFT + 1))
        fi
      fi
    done <<< "$entries"
  fi
done < <(find "$WIKI_DIR" -name '*.json' -type f)

if [ "$TRACKED" -eq 0 ]; then
  echo "freshness: no SHA tracking in this wiki — project schema does not record sources[].sha"
  exit 0
fi

if [ "$DRIFT" -gt 0 ]; then
  echo "freshness: $DRIFT page(s) reference stale sources"
  exit 1
fi

echo "freshness: clean ($TRACKED tracked references)"
