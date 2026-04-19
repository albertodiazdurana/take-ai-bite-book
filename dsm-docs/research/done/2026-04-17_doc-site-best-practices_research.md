# R3: Markdown Documentation Site Best Practices (MyST / Jupyter Book 2)

**Date:** 2026-04-17
**BL:** BACKLOG-001
**Status:** Done
**Date Completed:** 2026-04-19 (Session 4, Sprint 1 closure — H measurements recorded)
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

## Sprint 1 item H: Measurements from the first end-to-end build (2026-04-19)

**Run:** workflow_dispatch on `main`, `force=true`, GitHub Actions run [24626654340](https://github.com/albertodiazdurana/take-ai-bite-book/actions/runs/24626654340)
**Upstream tag built:** v1.5.3 (latest on take-ai-bite, from BL-376 auto-mirror; resolved via `scripts/check-upstream-version.sh`)
**Runner:** `ubuntu-latest`

### Three required metrics

| Metric | Value | Source of measurement |
|---|---|---|
| mystmd build wall time | **14 seconds** | Step 10 "Build HTML": 10:11:44Z → 10:11:58Z |
| Largest page load size | **83 KB** (85,391 bytes) | `site/index.html` in the Pages artifact. NOTE: mystmd built a *single-page* site for this content set; index.html IS the page load. |
| Search index size | **10 KB** (10,137 bytes) | `site/myst.search.json` (standard mystmd search-index JSON: `{version, records: [{hierarchy, content, url, position}]}`) |

### Full timing breakdown (all 13 build steps)

| Step | Name | Duration |
|---|---|---|
| 1 | Set up job | 2s |
| 2 | actions/checkout@v4 | 0s |
| 3 | Check upstream version | 0s |
| 4 | Clone upstream at tag | 1s |
| 5 | Copy upstream content | 0s |
| 6 | Inject version into myst.yml | 0s |
| 7 | Setup Pages | 0s |
| 8 | setup-node@v4 | 4s |
| 9 | Install mystmd (npm install -g) | 1s |
| 10 | **Build HTML (myst build --html)** | **14s** |
| 11 | Upload Pages artifact | 3s |
| 12 | Deploy to GitHub Pages | 6s |
| 13 | Commit .last-built-version back | 0s |
| | **Job wall time** | **33 seconds** |

### Artifact composition (unexpected finding)

The uploaded Pages artifact is **68 MB uncompressed (15.4 MB zipped)**. Of that:

- `build/_shared/plotly-ELWLZ5EC.js`: 14.5 MB (single largest file)
- `build/_shared/plotly-5BWH43UK.js`: 4.8 MB
- Five more `chunk-*.js` / `component-*.js` bundles: 1–4 MB each
- `thebe-core.min.js`: 1.3 MB (plus ~20 smaller `*.thebe-core.min.js` chunks)

The DSM content has no notebooks, no plotly charts, no interactive cells. The book-theme ships these runtimes unconditionally. **Sprint-2 optimization candidate:** strip unused executable-content runtime (plotly, thebe) from the theme build. This is an 18+ MB reduction (~90 % of the artifact) for a prose-only site.

### Single-HTML-file observation

mystmd produced **one HTML file** (`index.html`, 83 KB) for the whole 35-document DSM corpus. No per-chapter HTML. This is the mystmd book-theme default: an SPA that hydrates via JS and navigates via `history.pushState`, not a multi-page static site.

Implications:
- First-paint is the same across all "pages" — the 83 KB initial document is shared
- Subsequent "page" loads are data fetches, not HTML fetches
- The "largest page load" metric in the traditional sense (heaviest static HTML) is 83 KB, but the real first-load cost is HTML + the JS chunks required for hydration — the artifact breakdown above shows that cost is dominated by unused runtimes

### Gaps caught during H execution, captured as Sprint 1 lessons

Three setup-level failures prevented G from firing cleanly on the first three attempts. None were in the workflow code itself; all were in the repo / environment configuration surrounding it. These are captured as Session 4 feedback to DSM Central (`dsm-docs/feedback-to-dsm/2026-04-19_s4_*.md`):

1. **GitHub-configured default branch was `session-1/2026-04-17`, not `main`** — set at repo creation (2026-04-17) and never flipped. Sprint 1 merged to main, but GitHub's workflow-indexer only tracks the *configured* default branch, so `workflow_dispatch` 404'd with "workflow not found on the default branch" even though the file was present on main.
2. **A merge-commit from sprint branch → main does not trigger first-workflow registration** — GitHub's indexer needs a push that directly modifies a workflow file on the default branch. Required a separate PR (via ops branch) to touch `scheduled-build.yml` on main.
3. **The `github-pages` environment's branch-deployment policy pinned `session-1/2026-04-17`** — auto-created when Pages source was set to Actions, the policy captured the then-default branch. After flipping the default to main, the policy did not auto-update; the first post-flip dispatch failed in 4 seconds at the environment gate, before any workflow step ran.

**Closure signal:** after all three were addressed, run 24626654340 succeeded end-to-end in 33 seconds.

### Live site

Deployed to https://albertodiazdurana.github.io/take-ai-bite-book/ (propagation may take ~1 minute after workflow completion).

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
