#!/usr/bin/env bash
# copy-upstream-content.sh
#
# Copy the flat set of markdown files from the upstream (take-ai-bite, the
# public mirror of DSM Central) into a destination directory. Part of the
# Sprint 1 sync pipeline (BL-002 item B).
#
# Scope per Decision 0003 (updated Session 2): flat *.md glob from upstream
# root, no recursion. Files copied:
#   - DSM_*.md (core methodology documents)
#   - README.md, CHANGELOG.md, CONTRIBUTING.md, CODE_OF_CONDUCT.md
#   - FEATURES.md, LICENSE-DOCS.md, SECURITY.md, TAKE_A_BITE.md (public-
#     facing docs specific to take-ai-bite, not present in Central)
# LICENSE (plain text, no .md) is NOT copied; the site footer links to it
# directly in the upstream repo per Decision 0003.
#
# Usage:
#   scripts/copy-upstream-content.sh <UPSTREAM_DIR> <DEST_DIR>
#
# Exits:
#   0 on success (prints a "Copied N files" line to stdout)
#   1 on usage error or missing source directory

set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <UPSTREAM_DIR> <DEST_DIR>" >&2
  exit 1
fi

readonly UPSTREAM_DIR="$1"
readonly DEST_DIR="$2"

if [ ! -d "$UPSTREAM_DIR" ]; then
  echo "Error: UPSTREAM_DIR '$UPSTREAM_DIR' is not a directory" >&2
  exit 1
fi

mkdir -p "$DEST_DIR"

readonly PATTERNS=(
  "DSM_*.md"
  "README.md"
  "CHANGELOG.md"
  "CONTRIBUTING.md"
  "CODE_OF_CONDUCT.md"
  "FEATURES.md"
  "LICENSE-DOCS.md"
  "SECURITY.md"
  "TAKE_A_BITE.md"
)

count=0
for pattern in "${PATTERNS[@]}"; do
  while IFS= read -r -d '' file; do
    cp "$file" "$DEST_DIR/"
    count=$((count + 1))
  done < <(find "$UPSTREAM_DIR" -maxdepth 1 -type f -name "$pattern" -print0)
done

echo "Copied $count files from $UPSTREAM_DIR to $DEST_DIR"
