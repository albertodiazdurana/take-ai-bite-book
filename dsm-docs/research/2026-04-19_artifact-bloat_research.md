# Artifact bloat research

**Purpose:** Identify low-maintenance paths to reduce the deployed Pages artifact from ~68 MB uncompressed / ~15 MB zipped to something closer to the actual payload size of the prose-only DSM corpus. Produce a recommendation + scope estimate for the implementation BL (BACKLOG-004).

**Target outcome:** A recommendation with three ordered options (primary, fallback, safety-net), each with: mechanism, estimated size reduction, implementation cost (lines of code + risk surface), maintenance cost (upstream theme updates, re-verification on MyST version bumps), and a go/no-go signal for BACKLOG-004.

**Status:** In progress (Session 5, Sprint 2 Phase C, BACKLOG-003)

**Prerequisite reading:**
- `dsm-docs/checkpoints/done/2026-04-19_s4_sprint-1-close.md` — H measurements section (artifact sizes, search index, per-page sizes)
- `dsm-docs/research/done/2026-04-17_doc-site-best-practices_research.md` — item H's Sprint 1 measurements appendix

## Baseline evidence (known from Sprint 1)

From S4 checkpoint, run 24626654340 (Sprint 1's first green build):

| Metric | Value | Source |
|--------|-------|--------|
| mystmd build wall time | 14 s (step 10 of 13) | Run log |
| Job wall time (whole pipeline) | 33 s | Run log |
| Largest page load | 83 KB (`index.html`, single-page SPA) | `_build/html/` inspection |
| Search index size | 10 KB (`myst.search.json`) | `_build/html/` inspection |
| Pages artifact (zipped) | 15.4 MB | GitHub API: artifact 6517409032 |
| Pages artifact (uncompressed) | 68 MB | Manual extraction during S4 |

S4 checkpoint hypothesis (not yet independently verified):

> Artifact is 68 MB uncompressed / 15 MB zipped, dominated by plotly (~19 MB) + thebe (~1.3 MB + chunks) runtimes that the prose-only DSM corpus does not use. Stripping would reduce deploy size ~90%.

**First task of this research:** independently re-verify the plotly/thebe breakdown by downloading artifact 6517409032, extracting, and measuring by file pattern. S4's numbers came from a cursory inspection; this research file needs auditable per-file or per-directory measurements.

## Methodology

1. **Evidence phase.** Download the latest successful artifact. `du -sh` each subdirectory of `_build/html/`. Isolate JS chunks by runtime (plotly, thebe, other). Confirm or correct the S4 hypothesis.
2. **Mystmd theme/plugin inventory.** Read `book-theme` template source for any built-in option to disable executable-content runtimes. Check mystmd v1.8.3 release notes and option documentation. Check `myst.yml` option shape for `options.thebe` or equivalent. Distinguish: (a) "do not include the runtime at all" vs (b) "include but do not auto-activate."
3. **Post-build prune inventory.** Shell-level options: `find _build/html -name '*plotly*' -delete`, `find _build/html -name '*thebe*' -delete`, more surgical JS-chunk filters. Cost: risk of breaking legitimate usage (if any), brittleness on theme updates.
4. **Corpus audit.** Does the DSM corpus actually contain any executable content? If no MD file has ```{python}`` or ```{eval-rst}`` with live execution or interactive plots, removing the runtimes is safe. If yes, they must be preserved for the pages that use them.
5. **Comparison matrix.** Rows: options. Columns: size reduction, implementation cost, maintenance cost, risk. Rank.
6. **Recommendation.** Primary option + fallback + safety-net. Each with BL-004 acceptance criteria sketch.

## Evidence

### Artifact breakdown

(To be populated: download artifact 6517409032, extract, measure by directory and file pattern. Report `du -sh` results here.)

### Corpus audit

(To be populated: grep DSM content under `book/content/` for executable blocks. Quantify.)

## Option inventory

### Option 1: MyST theme/plugin option to disable runtimes

(To be populated.)

### Option 2: Post-build prune of runtime files

(To be populated.)

### Option 3: Theme fork removing runtime imports

(To be populated.)

## Comparison

| Option | Size reduction | Impl. cost | Maint. cost | Risk | Rank |
|--------|----------------|------------|-------------|------|------|
| 1 | TBD | TBD | TBD | TBD | TBD |
| 2 | TBD | TBD | TBD | TBD | TBD |
| 3 | TBD | TBD | TBD | TBD | TBD |

## Recommendation

(To be populated after evidence and option inventory are complete.)

## Scope estimate for BACKLOG-004

(To be populated: lines of code, files touched, testing protocol, rollback path.)

## Open questions

- Does the MyST `book-theme` template expose an option to disable the thebe runtime, or is thebe unconditionally included?
- Are plotly imports in the build eager (always included) or lazy (only if a `{plotly}` block is present)?
- What is the actual wire-size of each runtime (plotly.min.js, thebe.min.js, chunk files)?
- Does the build-time flag for mystmd (if any exists) affect search index quality or only the HTML payload?

## Session log

- **Session 5 (2026-04-19):** File created as Phase C kickoff, skeleton only. Evidence gathering deferred to next Sprint 2 session.
