# Decision 0003: Content Scope and Display Conventions

**Status:** Accepted
**Date:** 2026-04-17
**Session:** 1
**Related:** BACKLOG-001 (R4), `dsm-docs/research/2026-04-17_content-scope_research.md`, Decisions 0001 and 0002

---

## Context

Four scoping questions remained after Decisions 0001 (Jupyter Book 2)
and 0002 (scheduled cron sync) were settled: which Central files belong
in the book, how to handle `LICENSE`, which tags trigger a build, and
how the deployed site should display the DSM Central version.

## Decisions (bundle)

### 1. Source content scope (Q1)

The book renders `.md` files that live **directly in the DSM Central
repo root**. **Flat glob, no recursion into subfolders.**

- **In scope:** `DSM_*.md` (the methodology docs) plus `README.md`,
  `CHANGELOG.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`.
- **Out of scope:** any `.md` inside subfolders (`scripts/`, `.claude/`,
  `plan/`, `dsm-docs/`, etc.).
- The cron workflow's content-copy step is literally `cp central/*.md
  book/content/`, not a recursive walk.

### 2. LICENSE handling (Q1a)

`LICENSE` is at Central root but is plain text, not Markdown.

**Decision:** Footer link only. The site footer shows a "License" link
pointing at the LICENSE file in DSM Central's GitHub repository.
No build-time conversion to `LICENSE.md`.

### 3. Tag filter (Q2)

The cron workflow rebuilds **only on tags matching strict semver**:
regex `^v\d+\.\d+\.\d+$`.

- Outlier tags currently in Central (`pre-bl-202-strip`,
  `v1.3.0-consistency`) are ignored silently.
- Future release-candidate tags (`vX.Y.Z-rcN`, etc.) are also ignored.
  RCs are not deployed to the public docs site by intent.

### 4. Copy vs fetch (Q3)

**Build-time copy** from Central into this repo at workflow runtime.
No live fetch. Already mandated by Decision 0002 + the GitHub Pages
static-hosting requirement; recorded here for completeness.

### 5. Version display (Q4)

**Option C: title carries version, footer adds build date.**

- Site title (or `logo_text`): `"DSM Methodology — vX.Y.Z"`, where
  `vX.Y.Z` is the Central tag the build was for.
- Site footer: `"Built from DSM vX.Y.Z (YYYY-MM-DD)"`, where `YYYY-MM-DD`
  is the build date.
- Both fields read from the same build variables (Central tag + build
  timestamp) so there is one source of truth in the workflow.

## Rationale

- **Flat glob (Q1):** Removes ambiguity about future Central subfolder
  content. Any new `.md` added to a subfolder is automatically
  out-of-scope unless this decision is revisited.
- **Footer link for LICENSE (Q1a):** Zero build-time conversion,
  identical reader benefit. License is "in the book" by reference,
  which is normal for documentation sites.
- **Strict semver filter (Q2):** Existing outlier tags would either
  fail the build or confuse the version display. RCs are not target
  audience for the public docs.
- **Build-time copy (Q3):** Only path compatible with GH Pages static
  hosting + Decision 0002.
- **Title + footer for version (Q4):** Title sets immediate context;
  footer adds traceability for readers landing on the site months
  later. Both share the same build variables, so it is one source of
  truth in the workflow despite appearing in two places.

## Consequences

- The cron workflow's content-copy step is now fully specified:
  `cp central/*.md book/content/` (flat).
- The workflow's tag-detection step filters Central tags through
  `^v\d+\.\d+\.\d+$` before comparing against `.last-built-version`.
- The workflow's pre-build step rewrites `book/myst.yml`:
  `site.options.logo_text = "DSM Methodology — vX.Y.Z"`.
- The workflow's build-date injection (footer) will use whatever
  templating mechanism MyST exposes for footer text. Marked as
  verify-in-implementation in R3; if `myst.yml` cannot template the
  footer, a custom theme override is the fallback (and warrants a
  follow-up scope decision since custom themes increase maintenance).
- The site footer also includes a "License" link to Central's LICENSE
  file URL.

## References

- `dsm-docs/research/2026-04-17_content-scope_research.md` (R4
  evidence and recommended defaults)
- Decision 0001 (Jupyter Book 2 / MyST stack)
- Decision 0002 (scheduled cron sync mechanism)
- `_reference/preliminary-plan.md` §2 and §6 (original scope language
  and open questions)
