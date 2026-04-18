#!/usr/bin/env bash
# inject-version.sh
#
# Rewrite book/myst.yml in place with the upstream tag and build date. Part of
# the Sprint 1 sync pipeline (BL-002 item D). Run by scheduled-build.yml
# immediately before `myst build --html`.
#
# Fields rewritten (Decision 0003 version-display rule):
#   site.options.logo_text -> "DSM Methodology, {tag}"
#   site.parts.footer      -> "Built from DSM {tag} ({date}) · [License]({url})"
#
# The parts.footer block is the declarative hook exposed by the book-theme
# template (parts[].id = "footer" in the template's template.yml). Verified
# against mystmd v1.8.3 in Session 3: the block round-trips through the build
# as an mdast tree with full markdown rendering (text + link nodes).
#
# Usage:
#   scripts/inject-version.sh <TAG> <DATE>
#     TAG   : semver tag such as v1.5.3
#     DATE  : YYYY-MM-DD build date (usually $(date -u +%Y-%m-%d))
#
# Environment (optional overrides, used for local testing):
#   MYST_FILE    default: book/myst.yml
#   LICENSE_URL  default: take-ai-bite's LICENSE on main
#
# Exits:
#   0  on success (prints a one-line confirmation to stdout)
#   1  on usage error or missing myst.yml

set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <TAG> <DATE>" >&2
  exit 1
fi

readonly TAG="$1"
readonly DATE="$2"
readonly MYST_FILE="${MYST_FILE:-book/myst.yml}"
readonly LICENSE_URL="${LICENSE_URL:-https://github.com/albertodiazdurana/take-ai-bite/blob/main/LICENSE}"

if [ ! -f "$MYST_FILE" ]; then
  echo "Error: $MYST_FILE not found" >&2
  exit 1
fi

python3 - "$MYST_FILE" "$TAG" "$DATE" "$LICENSE_URL" <<'PY'
import pathlib, re, sys

path, tag, date, license_url = sys.argv[1:5]
p = pathlib.Path(path)
src = p.read_text()

src = re.sub(
    r'^(\s*logo_text:\s*).*$',
    lambda m: f"{m.group(1)}DSM Methodology, {tag}",
    src,
    count=1,
    flags=re.MULTILINE,
)

src = re.sub(r'(?ms)^  parts:\n(?:    .*\n)+', '', src)

if not src.endswith("\n"):
    src += "\n"
src += (
    "  parts:\n"
    "    footer: |\n"
    f"      Built from DSM {tag} ({date}) · [License]({license_url})\n"
)

p.write_text(src)
print(f"Injected tag={tag} date={date} into {path}")
PY
