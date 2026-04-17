# R3: Markdown Documentation Site Best Practices (MyST / Jupyter Book 2)

**Date:** 2026-04-17
**BL:** BACKLOG-001
**Status:** In progress (recommendation drafted, pending decision promotion)
**Author:** Alberto Diaz Durana

---

## Purpose

Identify patterns that should be adopted (or explicitly rejected) when
implementing the DSM Jupyter Book, given Decision 0001 (Jupyter Book 2 /
MyST) and Decision 0002 (scheduled cron sync from Central).

## Target Outcome

A list of adopted/rejected patterns with rationale and explicit
"verify-in-implementation" markers for items that cannot be concluded
from documentation alone.

---

## Findings

### 1. Multi-source content patterns

**Question:** How does a MyST book combine files from another repository
(in this case, files cloned from DSM Central)?

**Documentation signal:** MyST has no explicit "multi-repo" pattern. The
build is a single-tree operation: `mystmd` reads `myst.yml` and walks the
TOC, ingesting whichever Markdown / Jupyter Notebook files are present
on the filesystem. Cross-project linking exists via `xref` (links labels
in *another already-built* MyST project), but that is for cross-linking
deployed sites, not for combining sources at build time.

**Implication for this project:** The build-time content copy is the
right pattern. The cron workflow from Decision 0002 clones DSM Central
at the latest tag, copies the relevant files into `book/` (or wherever
MyST source root lives), then runs `mystmd build`. There is no MyST-native
"point at a remote repo" feature to substitute.

**Pattern adopted:**
- Source layout in this repo:
  - `book/` is the MyST source root
  - `book/myst.yml` is committed in this repo (book config, TOC, theme)
  - `book/content/` (or similar subdir) holds files copied from Central
    at build time; gitignored to keep this repo small and avoid version
    drift between commits
- The cron workflow's "copy" step is a flat copy of `DSM_*.md` plus
  community files (README, CONTRIBUTING, CODE_OF_CONDUCT, CHANGELOG,
  LICENSE) into the content subdir, then `mystmd build`

**Pattern rejected:** Git submodule pointing at DSM Central. Reason: the
cron workflow already does the equivalent of a checkout; a submodule
adds a second source-of-truth for "which Central version is current"
that has to stay in sync with `.last-built-version`. Two-source-of-truth
is the same anti-pattern Decision 0002 rejected for cross-repo coupling.

### 2. Version display

**Question:** How does the deployed site show *which DSM Central version*
it was built from?

**Documentation signal:** MyST `site.options` in `myst.yml` supports
`logo_text`, `logo_url`, custom CSS via `style`, and various footer/TOC
toggles. There is no documented dynamic version-injection mechanism, but
`logo_text` is a string and `myst.yml` is plain YAML the build pipeline
can rewrite.

**Pattern adopted:**
- The cron workflow rewrites a single line in `book/myst.yml` before
  build, injecting the Central tag as part of the site title or a
  custom footer string (via `style` if needed).
- Concretely: `site.options.logo_text` becomes
  `"DSM Methodology — vX.Y.Z"` where `vX.Y.Z` is the Central tag the
  build is for.
- An additional version string in the page footer is achievable via
  custom CSS (the `style` option) reading from a CSS variable the build
  injects, OR by templating `book/myst.yml` to add a `footer` override.

**Verify in implementation:** Whether MyST's footer is templatable from
config alone, or whether a custom theme is needed. If theme overrides
are needed, the maintenance footprint goes up; that would warrant a
follow-up decision.

### 3. Large markdown files (~7,800 lines like DSM_3)

**Question:** Does MyST handle DSM_3.md (and similar) without
performance issues or unusable navigation?

**Documentation signal:** MyST docs do not specify file-size limits and
do not document pagination. The general guidance is "divide content into
multiple files and organize hierarchically rather than handle as single
monolithic documents." MyST emphasizes structural organization over
auto-pagination.

This means: a 7,800-line file *will* be parsed and rendered, but
reader-friendliness comes from the heading-anchor TOC (`{toc}`
directive), not from MyST splitting the page automatically.

**Performance signal:** MyST claims sub-150ms local rebuilds and
prefetching for fast navigation, but these claims are about the framework,
not specifically about 7,800-line single-page parsing.

**Pattern (provisional, verify in implementation):**
- Build with files as-is initially. Use the page-level `{toc}` directive
  to render an in-page TOC from headings so the long file is navigable.
- Measure: time `mystmd build` with full DSM content; check rendered
  page size and initial load time.
- Decision criterion (from project requirements: reader-friendly):
  - If initial page load > ~3s on a typical connection, OR
  - Page TOC has > ~50 headings without grouping
  - then split the largest files at H2 boundaries (one MyST file per
    H2 section), regenerate TOC entries in `myst.yml`. This is a
    build-time transform, not a Central-side change.

**Verify in implementation:** Actual numbers, not speculation. R3 cannot
conclude this from documentation alone.

### 4. Search at scale

**Question:** Does MyST's built-in search scale to ~30k lines of total
DSM content?

**Documentation signal:** MyST's website templates include client-side
search out of the box. Search index size scales roughly linearly with
content; for a methodology corpus (~30k lines, mostly prose with code
fences), the index is likely in the hundreds-of-KB range, comfortably
within typical client-side search bounds.

**Pattern adopted:**
- Use the default search shipped with `book-theme`.
- Do not introduce Algolia DocSearch or external search until/unless a
  measured deficiency emerges.

**Reason for not researching further:** Adding search infrastructure
when the built-in option likely works conflicts with minimal-maintenance.
Defer until evidence appears.

### 5. Theme selection

**Question:** Which built-in template fits a methodology documentation
site?

**Documentation signal:** MyST ships two templates:
- `book-theme` (default): "Simple site for displaying multiple articles
  and notebooks with a table of contents"
- `article-theme`: For scientific documents with supporting notebooks

**Pattern adopted:** `book-theme`. DSM is a methodology with multiple
documents and a TOC, not a scientific article with supporting notebooks.

---

## Recommendations summary

| Pattern | Decision | Notes |
|---------|----------|-------|
| Multi-source via build-time copy from Central | **Adopt** | Cron workflow already does this; no MyST-native multi-repo feature |
| Git submodule of Central | **Reject** | Two-source-of-truth anti-pattern |
| Version display via `logo_text` rewrite | **Adopt** | Build pipeline edits `myst.yml` |
| Custom theme for footer version string | **Defer** (verify in impl) | Try config-only first; theme overrides increase maintenance |
| Build large files as-is, page-level `{toc}` for navigation | **Adopt (provisional)** | Verify with measured rebuild + load times |
| Split at H2 if pages too large | **Defer** (criterion documented) | Build-time transform, no Central change |
| Default `book-theme` search | **Adopt** | No external search infra unless evidence demands |
| External search (Algolia, etc.) | **Reject for now** | Conflicts with minimal-maintenance |
| `book-theme` template | **Adopt** | Methodology = multi-doc + TOC, fits the theme |
| `article-theme` template | **Reject** | Wrong shape for methodology corpus |

## Open follow-ups

- Implementation must produce real measurements for:
  - `mystmd build` time on full DSM content
  - Largest single-page render size and load time
  - Search index size and search responsiveness on a representative query
- If any measurement misses the criterion, file a follow-up BL for that
  specific item rather than hand-tuning during implementation.
- R4 (content scoping) addresses: case-studies inclusion, every-tag vs
  release-only, copy vs fetch, version display source. Some R3 patterns
  depend on R4 outcomes (e.g., version display source is "the tag the
  cron built from", but R4 decides which tags qualify).

---

## Sources

- [MyST Markdown overview — Jupyter Book User Guide](https://jupyterbook.org/v1/content/myst.html)
- [Towards Jupyter Book 2 with MyST-MD — executablebooks.org](https://executablebooks.org/en/latest/blog/2024-05-20-jupyter-book-myst/)
- [Jupyter Book 2 and the MyST Document Stack — SciPy Proceedings](https://proceedings.scipy.org/articles/hwcj9957)
- [MyST Table of Contents guide](https://mystmd.org/guide/table-of-contents)
- [MyST Website Templates guide](https://mystmd.org/guide/website-templates)
- [MyST Accessibility and Performance](https://mystmd.org/guide/accessibility-and-performance)
- [MyST Markdown — main site](https://mystmd.org/)
- [mystmd CLI — GitHub](https://github.com/jupyter-book/mystmd)
