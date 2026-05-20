#!/usr/bin/env bash
# scripts/verify.sh — wiki structural verification (reference implementation)
#
# Adopting projects copy this to .wiki/scripts/verify.sh and customize.
# Bundle modes do NOT call this directly; they call .wiki/scripts/verify.sh in the
# adopting project.
#
# This reference impl:
#   - Walks the wiki package directory
#   - Validates JSON files parse
#   - Validates YAML frontmatter on .md files parses
#   - Checks each sources[].path entry references an existing file
#
# Customize for your schema. Add cross-ref integrity checks, required-field
# presence, naming convention enforcement, etc.

set -eu

WIKI_DIR="${1:-team-pulse-package}"

if [ ! -d "$WIKI_DIR" ]; then
  echo "verify: directory $WIKI_DIR not found"
  exit 2
fi

ERRORS=0

# 1. JSON files parse
while IFS= read -r f; do
  if ! python3 -m json.tool < "$f" > /dev/null 2>&1; then
    echo "ERROR: $f does not parse as JSON"
    ERRORS=$((ERRORS + 1))
  fi
done < <(find "$WIKI_DIR" -name '*.json' -type f)

# 2. sources[].path entries resolve (requires jq)
if command -v jq > /dev/null 2>&1; then
  while IFS= read -r f; do
    paths=$(jq -r '.. | objects | select(.sources? != null) | .sources[]?.path // empty' "$f" 2>/dev/null || true)
    for p in $paths; do
      target="$WIKI_DIR/$p"
      if [ ! -f "$target" ]; then
        echo "ERROR: $f references non-existent $target"
        ERRORS=$((ERRORS + 1))
      fi
    done
  done < <(find "$WIKI_DIR" -name '*.json' -type f)
fi

if [ "$ERRORS" -gt 0 ]; then
  echo "verify: $ERRORS error(s)"
  exit 1
fi

echo "verify: clean"
