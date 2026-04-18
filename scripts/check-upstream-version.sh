#!/usr/bin/env bash
# check-upstream-version.sh
#
# Determine whether the book needs rebuilding against a newer take-ai-bite
# release. Queries take-ai-bite's tags via `gh api`, filters to strict semver,
# and compares the highest matching tag against .last-built-version at repo
# root. Part of the Sprint 1 sync pipeline (BL-002 item C).
#
# Upstream and tag format per Decisions 0002 + 0003 (updated S3):
#   - Repo: github.com/albertodiazdurana/take-ai-bite (public)
#   - Semver filter: ^v[0-9]+\.[0-9]+\.[0-9]+$ (strict, no RCs / suffixes)
#   - Tag mirroring from DSM Central to take-ai-bite is handled by Central's
#     BL-376 /dsm-version-update Step 4b; this script only reads the tags.
#
# Usage:
#   scripts/check-upstream-version.sh
#
# Environment (optional overrides, used for local testing):
#   UPSTREAM_REPO    default: albertodiazdurana/take-ai-bite
#   LAST_BUILT_FILE  default: .last-built-version (at repo root)
#
# Exits:
#   0  no rebuild needed (latest == last-built)
#   10 rebuild needed; the new tag is printed to stdout
#   1  error (missing dependency, API failure, no tags matching the filter)

set -euo pipefail

readonly UPSTREAM_REPO="${UPSTREAM_REPO:-albertodiazdurana/take-ai-bite}"
readonly LAST_BUILT_FILE="${LAST_BUILT_FILE:-.last-built-version}"
readonly SEMVER_RE='^v[0-9]+\.[0-9]+\.[0-9]+$'

if ! command -v gh >/dev/null 2>&1; then
  echo "Error: gh CLI not found on PATH" >&2
  exit 1
fi

if [ -f "$LAST_BUILT_FILE" ]; then
  last_built="$(cat "$LAST_BUILT_FILE")"
else
  last_built=""
fi

# Query all tags, filter to strict semver, pick highest via `sort -V`.
latest="$(
  gh api "repos/$UPSTREAM_REPO/tags" --paginate --jq '.[].name' \
    | grep -E "$SEMVER_RE" \
    | sort -V \
    | tail -n 1
)"

if [ -z "$latest" ]; then
  echo "Error: no tags matching $SEMVER_RE on $UPSTREAM_REPO" >&2
  exit 1
fi

if [ "$latest" = "$last_built" ]; then
  exit 0
fi

echo "$latest"
exit 10
