#!/usr/bin/env bash
# scripts/publish.sh — STUB
#
# Adopting projects MUST replace this with their publish step.
# This stub exists to give /wiki-publish something to call during development
# before the project's policy is finalized.
#
# Examples of what to put here:
#   - zip wiki.zip wiki/
#   - rsync wiki/ user@host:/var/www/wiki/
#   - git push to a publish remote
#   - HTTP POST to a content API
#   - aws s3 sync wiki/ s3://bucket/

set -eu

cat <<EOF
publish.sh — STUB

No publish target configured. Replace this script with your project's publish step.

This stub is a placeholder so /wiki-publish can be exercised end-to-end during
bundle adoption and dogfooding. It does nothing.
EOF
