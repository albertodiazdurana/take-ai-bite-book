#!/usr/bin/env bash
# copy-central-content.sh
#
# Copy the flat set of markdown files from a DSM Central checkout into a
# destination directory. Part of the Sprint 1 sync pipeline (BL-002 item B).
#
# Scope per Decision 0003: flat *.md glob from Central root, no recursion.
# Files copied:
#   - DSM_*.md (core methodology documents)
#   - README.md, CHANGELOG.md, CONTRIBUTING.md, CODE_OF_CONDUCT.md
# LICENSE is NOT copied; the site footer links to it directly in Central.
#
# Usage:
#   scripts/copy-central-content.sh <CENTRAL_DIR> <DEST_DIR>
#
# Exits:
#   0 on success (prints a "Copied N files" line to stdout)
#   1 on usage error or missing source directory

set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <CENTRAL_DIR> <DEST_DIR>" >&2
  exit 1
fi

readonly CENTRAL_DIR="$1"
readonly DEST_DIR="$2"

if [ ! -d "$CENTRAL_DIR" ]; then
  echo "Error: CENTRAL_DIR '$CENTRAL_DIR' is not a directory" >&2
  exit 1
fi

mkdir -p "$DEST_DIR"

readonly PATTERNS=(
  "DSM_*.md"
  "README.md"
  "CHANGELOG.md"
  "CONTRIBUTING.md"
  "CODE_OF_CONDUCT.md"
)

count=0
for pattern in "${PATTERNS[@]}"; do
  while IFS= read -r -d '' file; do
    cp "$file" "$DEST_DIR/"
    count=$((count + 1))
  done < <(find "$CENTRAL_DIR" -maxdepth 1 -type f -name "$pattern" -print0)
done

echo "Copied $count files from $CENTRAL_DIR to $DEST_DIR"
