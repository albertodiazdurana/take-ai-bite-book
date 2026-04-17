# Decision 0003: Content Scope and Display Conventions

**Status:** Accepted (upstream corrected + scope extended Session 2)
**Date:** 2026-04-17
**Session:** 1 (authored), Session 2 (upstream + scope corrected)
**Related:** BACKLOG-001 (R4), `dsm-docs/research/2026-04-17_content-scope_research.md`, Decisions 0001 and 0002

---

## Session 2 corrections

1. **Upstream name.** Session 1 named the upstream as "DSM Central". The
   actual upstream is `take-ai-bite` (public mirror subset of Central).
   Wording throughout this file has been updated.
2. **Scope extension.** take-ai-bite contains 4 public-facing `.md` files
   that do not exist in Central's scope set: `FEATURES.md`,
   `LICENSE-DOCS.md`, `SECURITY.md`, `TAKE_A_BITE.md`. These are added
   to the in-scope list. Total: 43 files from take-ai-bite root
   (35 DSM_*.md + 4 community + 4 public-facing extras).

---

## Context

Four scoping questions remained after Decisions 0001 (Jupyter Book 2)
and 0002 (scheduled cron sync) were settled: which upstream files belong
in the book, how to handle `LICENSE`, which tags trigger a build, and
how the deployed site should display the upstream version.

## Decisions (bundle)

### 1. Source content scope (Q1)

The book renders `.md` files that live **directly in the `take-ai-bite`
repo root**. **Flat glob, no recursion into subfolders.**

- **In scope:** `DSM_*.md` (the 35 methodology docs) plus the 4 community
  files (`README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`,
  `CODE_OF_CONDUCT.md`) plus the 4 public-facing extras
  (`FEATURES.md`, `LICENSE-DOCS.md`, `SECURITY.md`, `TAKE_A_BITE.md`).
  **Total: 43 files from take-ai-bite root as of 2026-04-18.**
- **Out of scope:** any `.md` inside subfolders (`scripts/`, `.claude/`,
  `plan/`, `dsm-docs/`, etc.).
- The cron workflow's content-copy step is literally `cp upstream/*.md
  book/content/` against the explicit pattern list, not a recursive walk.

### 2. LICENSE handling (Q1a)

`LICENSE` is at take-ai-bite root but is plain text, not Markdown.
take-ai-bite also carries a separate `LICENSE-DOCS.md` (Markdown) for
the documentation content, which IS in the copy scope above.

**Decision:** Footer link only for the root `LICENSE`. The site footer
shows a "License" link pointing at the `LICENSE` file in take-ai-bite's
GitHub repository. No build-time conversion to `LICENSE.md`. The
separate `LICENSE-DOCS.md` is included via the normal content copy.

### 3. Tag filter (Q2)

The cron workflow rebuilds **only on tags matching strict semver**:
regex `^v\d+\.\d+\.\d+$`.

- Outlier tags (e.g., `pre-bl-202-strip`, `v1.3.0-consistency` in Central)
  are ignored silently. take-ai-bite should mirror only semver tags from
  Central; any outliers mirrored in would also be filtered out.
- Future release-candidate tags (`vX.Y.Z-rcN`, etc.) are also ignored.
  RCs are not deployed to the public docs site by intent.
- **Session 2 status:** take-ai-bite currently has zero tags (mirrored or
  otherwise). Resolution options documented in BL-002 Open issues.

### 4. Copy vs fetch (Q3)

**Build-time copy** from Central into this repo at workflow runtime.
No live fetch. Already mandated by Decision 0002 + the GitHub Pages
static-hosting requirement; recorded here for completeness.

### 5. Version display (Q4)

**Option C: title carries version, footer adds build date.**

- Site title (or `logo_text`): `"DSM Methodology — vX.Y.Z"`, where
  `vX.Y.Z` is the take-ai-bite tag the build was for.
- Site footer: `"Built from DSM vX.Y.Z (YYYY-MM-DD)"`, where `YYYY-MM-DD`
  is the build date.
- Both fields read from the same build variables (upstream tag + build
  timestamp) so there is one source of truth in the workflow.

## Rationale

- **Flat glob (Q1):** Removes ambiguity about future upstream subfolder
  content. Any new `.md` added to a subfolder is automatically
  out-of-scope unless this decision is revisited.
- **Footer link for LICENSE (Q1a):** Zero build-time conversion,
  identical reader benefit. License is "in the book" by reference,
  which is normal for documentation sites.
- **Strict semver filter (Q2):** Outlier tags mirrored from Central would
  either fail the build or confuse the version display. RCs are not
  target audience for the public docs.
- **Build-time copy (Q3):** Only path compatible with GH Pages static
  hosting + Decision 0002.
- **Title + footer for version (Q4):** Title sets immediate context;
  footer adds traceability for readers landing on the site months
  later. Both share the same build variables, so it is one source of
  truth in the workflow despite appearing in two places.

## Consequences

- The cron workflow's content-copy step is now fully specified:
  the 43-file flat set (35 DSM_*.md + 4 community + 4 public-facing
  extras) copied from take-ai-bite root to `book/content/`,
  implemented by `scripts/copy-upstream-content.sh`.
- The workflow's tag-detection step filters take-ai-bite tags through
  `^v\d+\.\d+\.\d+$` before comparing against `.last-built-version`.
- The workflow's pre-build step rewrites `book/myst.yml`:
  `site.options.logo_text = "DSM Methodology — vX.Y.Z"`.
- The workflow's build-date injection (footer) will use whatever
  templating mechanism MyST exposes for footer text. Marked as
  verify-in-implementation in R3; if `myst.yml` cannot template the
  footer, a custom theme override is the fallback (and warrants a
  follow-up scope decision since custom themes increase maintenance).
- The site footer also includes a "License" link to take-ai-bite's
  LICENSE file URL.

## References

- `dsm-docs/research/2026-04-17_content-scope_research.md` (R4
  evidence and recommended defaults)
- Decision 0001 (Jupyter Book 2 / MyST stack)
- Decision 0002 (scheduled cron sync mechanism)
- `_reference/preliminary-plan.md` §2 and §6 (original scope language
  and open questions)
