# R4: Content Scoping Decisions

**Date:** 2026-04-17
**BL:** BACKLOG-001
**Status:** Done
**Date Completed:** 2026-04-17
**Outcome:** Promoted to `dsm-docs/decisions/0003_content-scope.md` (Accepted, bundle: Q1+Q1a+Q2+Q3+Q4)
**Author:** Alberto Diaz Durana

---

## Purpose

Settle the four content/process scoping questions from
`_reference/preliminary-plan.md` §6 that need user input rather than
web research.

## Target Outcome

Four answered questions, each with rationale, that can be promoted to
a single `dsm-docs/decisions/0003_content-scope.md` ADR.

---

## Q1. Should `case-studies/` be included in the book?

**ANSWERED (Session 1):** No case-studies. User clarification 2026-04-17:
"The scope of this book is to display on the internet, in a human-
readable way, the main DSM files in TAB — these are all md files in
the root folder."

### Source glob (sharpened scope rule)

The book renders `.md` files that live **directly in the DSM Central
repo root**. Flat glob, no recursion into subfolders.

In scope:
- `DSM_*.md` — the methodology docs (35 files as of 2026-04-17)
- `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`
  — community docs

Out of scope:
- Any `.md` inside subfolders (`scripts/`, `.claude/`, `plan/`,
  `dsm-docs/`, etc.) — even though they may exist, they do NOT ship
  to the book.
- Non-`.md` files in the root, EXCEPT see Q1a below for `LICENSE`.

The cron workflow's "copy" step uses a flat glob (`*.md` from Central
root), not a recursive walk.

### Q1a. (open sub-question)

`LICENSE` is at Central root but is a plain text file, not Markdown.
Documentation sites typically include the license either as a footer
link or as a dedicated page. Two options:

- **Include:** Convert LICENSE to a Markdown page (`LICENSE.md`
  wrapper) so it shows up in the book TOC. Adds one build-time step.
- **Footer link only:** Add a "License" link in the site footer
  pointing to the LICENSE file in Central's GitHub repo. No build-time
  conversion.

**Recommended default:** Footer link only. Reader-facing benefit is
identical and there's no content transformation to maintain.

**User decision needed:** Include or footer-link?

---

## Q2. Build on every tag, or only release tags matching `vX.Y.Z`?

**Evidence from DSM Central inspection:**
- 29 total tags in Central. 27 match `vX.Y.Z` (semver release tags).
- 2 non-semver outliers:
  - `pre-bl-202-strip` (cleanup checkpoint tag, not a release)
  - `v1.3.0-consistency` (variant, not a clean release)
- A naive "build on every tag" cron would attempt to build at these
  outliers and either confuse the version display or fail.

**Recommended default:** **Build only on tags matching `^v\d+\.\d+\.\d+$`**
(strict semver, no suffixes). The cron workflow filters Central's tag
list with this regex before deciding whether to rebuild. Outlier tags
are ignored silently.

**User decision needed:** Accept default, or use a different filter
(e.g., allow `vX.Y.Z` and `vX.Y.Z-rcN` for release candidates; or
include all tags and let the build fail loudly on the outliers)?

---

## Q3. Copy content into book repo at build, or fetch from Central live?

**Already settled by R2 + R3.** Listed here for explicit confirmation:

- Decision 0002 (sync mechanism) chose scheduled cron + build-time copy.
- R3 confirmed MyST has no native multi-repo / live-fetch feature.
- A live-fetch alternative (e.g., serving Markdown rendered at request
  time) would require server-side runtime, conflicting with GitHub
  Pages = static hosting.

**Recommended default:** **Build-time copy from Central, no live fetch.**
This is the only mechanism compatible with both Decision 0002 and the
GitHub Pages requirement.

**User decision needed:** None expected — confirming for the record.

---

## Q4. How to display DSM version in site title/footer?

**Already partially settled by R3.** Listed here for explicit confirmation
on display-string format.

R3 recommended rewriting `book/myst.yml` `site.options.logo_text` at
build time with the Central tag.

**Open sub-question (display string format):**
- Option A: `"DSM Methodology — vX.Y.Z"` (title + version)
- Option B: `"DSM Methodology"` in title, `"Built from DSM vX.Y.Z (YYYY-MM-DD)"`
  in footer (separation of concerns)
- Option C: Both — title shows latest version always; footer adds the
  build date for traceability

**Recommended default:** **Option C.** Title gets the version (always
visible, sets reader expectation). Footer adds the build date so a
reader landing on the site months later can tell "yes this is current"
without checking commit history. Build date is free metadata; the cron
already knows when it ran.

**User decision needed:** Choose A / B / C, or propose D.

**Verify in implementation:** Whether the footer text is configurable
from `myst.yml` alone, or whether a custom theme override is needed
(R3 marked this as verify-in-implementation).

---

## Summary table

| Question | Recommended default | User decision needed? |
|----------|---------------------|----------------------|
| Q1 case-studies | ANSWERED: no case-studies; flat *.md from Central root | No (answered) |
| Q1a LICENSE | Footer link only (no .md wrapper) | Yes, include or footer-link |
| Q2 tag filter | Strict semver `^v\d+\.\d+\.\d+$` | Yes, accept or relax/tighten |
| Q3 copy vs fetch | Build-time copy (already decided) | No, confirmation only |
| Q4 version display | Option C (title + footer with date) | Yes, choose A/B/C/D |

## Promotion path

Once user answers Q1, Q2, Q4 (and confirms Q3), promote to
`dsm-docs/decisions/0003_content-scope.md` as a single self-contained
ADR. R4 research file then marked Done and moved to
`dsm-docs/research/done/`.

## Sources

- DSM Central filesystem inspection (2026-04-17): `ls`, `git tag`
- `_reference/preliminary-plan.md` §6 (origin of these questions)
- Decision 0001 (Jupyter Book 2)
- Decision 0002 (scheduled cron sync)
- R3 research (`dsm-docs/research/2026-04-17_doc-site-best-practices_research.md`)
