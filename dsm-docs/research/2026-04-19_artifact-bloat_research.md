# Artifact bloat research

**Purpose:** Identify low-maintenance paths to reduce the deployed Pages artifact from ~68 MB uncompressed / ~15 MB zipped to something closer to the actual payload size of the prose-only DSM corpus. Produce a recommendation + scope estimate for the implementation BL (BACKLOG-004).

**Target outcome:** A recommendation with three ordered options (primary, fallback, safety-net), each with: mechanism, estimated size reduction, implementation cost (lines of code + risk surface), maintenance cost (upstream theme updates, re-verification on MyST version bumps), and a go/no-go signal for BACKLOG-004.

**Status:** Complete (Session 6, Sprint 2 Phase C, BACKLOG-003). Recommendation: Option 2 (post-build prune). Ready for BACKLOG-004 formalization.

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

S4 checkpoint hypothesis (audited in Session 6, partially corrected):

> Artifact is 68 MB uncompressed / 15 MB zipped, dominated by plotly (~19 MB) + thebe (~1.3 MB + chunks) runtimes that the prose-only DSM corpus does not use. Stripping would reduce deploy size ~90%.

**Audit result (see Evidence section):** The plotly/thebe size claim is correct within rounding (plotly 18.43 MB, thebe 3.83 MB, combined 22.26 MB), but the "~90 % reduction" claim is wrong. Plotly + thebe together are **31 %** of the artifact, not 90 %. The remaining ~45 MB is MyST's framework chunk bundle (React/Remix), which was not visible in the S4 cursory inspection. The corpus-has-no-executable-content claim IS correct: zero executable-content directives across all 43 DSM_*.md files.

## Methodology

1. **Evidence phase.** Download the latest successful artifact. `du -sh` each subdirectory of `_build/html/`. Isolate JS chunks by runtime (plotly, thebe, other). Confirm or correct the S4 hypothesis.
2. **Mystmd theme/plugin inventory.** Read `book-theme` template source for any built-in option to disable executable-content runtimes. Check mystmd v1.8.3 release notes and option documentation. Check `myst.yml` option shape for `options.thebe` or equivalent. Distinguish: (a) "do not include the runtime at all" vs (b) "include but do not auto-activate."
3. **Post-build prune inventory.** Shell-level options: `find _build/html -name '*plotly*' -delete`, `find _build/html -name '*thebe*' -delete`, more surgical JS-chunk filters. Cost: risk of breaking legitimate usage (if any), brittleness on theme updates.
4. **Corpus audit.** Does the DSM corpus actually contain any executable content? If no MD file has ```{python}`` or ```{eval-rst}`` with live execution or interactive plots, removing the runtimes is safe. If yes, they must be preserved for the pages that use them.
5. **Comparison matrix.** Rows: options. Columns: size reduction, implementation cost, maintenance cost, risk. Rank.
6. **Recommendation.** Primary option + fallback + safety-net. Each with BL-004 acceptance criteria sketch.

## Evidence

### Artifact breakdown

Measured against artifact **6525506268** (run 24652216077, the first scheduled `event=schedule` fire at 2026-04-20T06:39:39Z). Size numbers match artifact 6517409032 within 15 KB (15.47 MB vs 15.46 MB zipped), so the Sprint 1 artifact would have given the same result; using the newer artifact keeps the evidence current.

**Totals:**

| Scope | Size (uncompressed) | % of total |
|-------|---------------------|------------|
| Whole artifact (`site/`) | 72 MB | 100.0 % |
| `build/` | 68 MB | 94.4 % |
| `build/_shared/` (runtimes + chunks) | 67 MB | 93.1 % |
| All `.js` files | 64.82 MB | 90.0 % |
| Non-JS, non-MD, non-HTML, non-CSS | 0.16 MB | 0.2 % |

**By file pattern (cross-cutting, pattern-matched):**

| Pattern | Size | % of total | Notes |
|---------|------|------------|-------|
| `*plotly*` | 18.43 MB | 25.6 % | 2 files: plotly-ELWLZ5EC.js (13.87 MB) + plotly-5BWH43UK.js (4.55 MB). Two variants present; only one loaded at runtime, but both shipped. |
| `*thebe*` | 3.83 MB | 5.3 % | ~30 files: thebe-core, thebe-lite, chunked variants. Some at site root (1.3 MB thebe-core.min.js), most under `build/_shared/`. |
| `chunk-*.js` + `dist-*.js` + `component-*.js` | 35.32 MB | 49.1 % | Unnamed hashed chunks. MyST + Remix + React bundles; not individually identifiable without source-map or build-manifest inspection. |
| **Runtime libs (plotly+thebe+bokeh+d3)** | **22.36 MB** | **31.1 %** | Known-named interactive runtimes. |

**Top 15 individual files (from `build/_shared/`):**

| Rank | File | Size |
|------|------|------|
| 1 | plotly-ELWLZ5EC.js | 13.87 MB |
| 2 | plotly-5BWH43UK.js | 4.55 MB |
| 3 | chunk-IW6XPN43.js | 3.87 MB |
| 4 | chunk-XF6KJEBA.js | 3.84 MB |
| 5 | chunk-QYHIDYQN.js | 3.62 MB |
| 6 | chunk-WVBTC5H5.js | 2.09 MB |
| 7 | chunk-C4DFGG5C.js | 1.59 MB |
| 8 | chunk-M7I6MSNA.js | 1.43 MB |
| 9 | component-2I35LYEA.js | 1.15 MB |
| 10 | chunk-NT723IVF.js | 1.02 MB |
| 11 | chunk-3RNZ6DIW.js | 0.96 MB |
| 12 | chunk-QKSCEHAD.js | 0.91 MB |
| 13 | chunk-3I3NFLZ5.js | 0.71 MB |
| 14 | dist-XPT4CEBR.js | 0.71 MB |
| 15 | chunk-5TL5RV2T.js | 0.64 MB |

**Correction to S4 hypothesis.** S4's "~90% plotly + thebe" claim does not hold on audit.

- Plotly + thebe together: **22.26 MB (31 % of total)**, not ~90 %.
- The remaining ~45 MB of JS is **unnamed hashed chunks** (chunk-*, dist-*, component-*) that comprise MyST's React/Remix frontend bundle. These were not visible in S4's cursory inspection.
- The "prose-only DSM corpus doesn't need plotly/thebe" claim IS correct (see Corpus audit below), so stripping plotly + thebe is safe and recovers 31 % (22 MB).
- Reaching the S4-claimed ~90 % reduction would require also pruning or tree-shaking the chunk bundle, which is substantially harder because the chunks carry genuine site code (navigation, search, cross-references, admonitions, theme features) that IS used.

### Corpus audit

Scanned all 43 `.md` files at the root of the upstream `~/dsm-take-ai-bite` repo for executable-content directives:

```
grep -rn '```{python}\|```{eval-rst}\|:::{thebe}\|thebe:\s*true' *.md
```

**Result: zero matches.** The DSM corpus is entirely prose; no live code execution, no interactive plots, no jupyter widgets. Stripping plotly + thebe runtimes has **no user-visible impact on site functionality**.

## Option inventory

### Option 1: MyST theme/plugin option to disable runtimes

**Finding: no documented flag exists.** Searched:

- `mystmd.org/guide/website-templates` , book-theme site options list (hide_toc, hide_footer_links, logo, analytics, style, etc.). No option references thebe or plotly inclusion.
- `mystmd.org/guide/execute-notebooks` , documents runtime execution behavior but no `--no-thebe` / `--no-plotly` build flag or opt-out config.
- `mystmd.org/thebe/options` , documents thebe's CoreOptions (useBinder, useJupyterLite, serverSettings). These control **runtime connection behavior**, not bundle inclusion. Setting them all to false still ships thebe JS to the client.
- `github.com/jupyter-book/myst-theme docs/ui.md` , covers `site.parts` / `project.parts` (logos, banners, footers, visibility toggles). No runtime-exclusion option.

Current `book/myst.yml` declares only `logo_text` under `site.options`, consistent with a prose site with no executable content.

**Conclusion:** In mystmd v1.8.3 / `book-theme` current, the runtime bundle is **unconditionally included** regardless of whether the corpus actually uses thebe or plotly. No first-class opt-out path exists.

**Impl. cost:** 0 (nothing to implement; option unavailable).
**Maint. cost:** 0.
**Size reduction:** 0 MB (option not feasible).
**Risk:** N/A.

**Go/no-go:** No-go as a primary option. Keep the finding documented; if a future mystmd release adds such a flag, this becomes the zero-cost primary.

### Option 2: Post-build prune of runtime files

**Mechanism:** After `myst build`, before artifact upload, run targeted `find`-based deletes on `book/_build/html/` to remove plotly and thebe bundles. Example:

```bash
find book/_build/html -name '*plotly*.js' -delete
find book/_build/html -name '*thebe*' \( -name '*.js' -o -name '*.css' \) -delete
```

Added as a new step in `.github/workflows/scheduled-build.yml` between the `myst build` step and the `upload-pages-artifact` step.

**Estimated size reduction:** 22.26 MB (31 % of total), from 72 MB → ~50 MB uncompressed; 15.47 MB → ~11 MB zipped (rough estimate, actual savings depend on gzip ratio on the deleted files).

**Impl. cost:** ~5 lines of YAML (one workflow step, two `find` commands, a confirmation `du -sh`). Low.

**Maint. cost:** Low. The file-name patterns (`*plotly*`, `*thebe*`) are stable across mystmd minor versions; hashed-suffix changes don't break the glob. A major version of book-theme that renames the bundle (e.g., to `runtime-plotly-*.js`) would break the prune, but that is a breaking upstream change that would also warrant re-verification of other assumptions. On a mystmd version bump, re-run this research to confirm names.

**Risk:** Medium. The primary risk is that the book-theme framework chunks have **unconditional import** statements for plotly/thebe. If so, deleting the files causes a browser JavaScript error when the chunk runs, even on prose-only pages. **Mitigation:** verify post-prune by opening the built site locally (`python -m http.server` in `_build/html/`) and checking (a) the browser console for errors on the index page and a representative DSM page, (b) the Network tab for failed requests. If errors appear, fall back to a less aggressive prune or to Option 3.

**Go/no-go:** Go as primary option, contingent on post-prune validation passing.

### Option 3: Theme fork removing runtime imports

**Mechanism:** Fork `@myst-theme/book-theme` to a private npm package (e.g., `@alberto/book-theme-noexec`), remove the plotly and thebe imports from the theme's frontend entry points, publish, and point `site.template` in `myst.yml` at the fork.

**Estimated size reduction:** 22.26 MB (same as Option 2 in size, but achieved earlier in the pipeline).

**Impl. cost:** High. Requires: (a) forking the repo, (b) locating and removing runtime imports without breaking the chunk graph, (c) setting up npm publishing, (d) configuring the build to use the fork. Estimated 4-8 hours for a first-pass working fork, plus verification.

**Maint. cost:** High. The fork must be kept in sync with upstream `myst-theme` releases. Each upstream release requires re-applying the import removal, re-testing, re-publishing. Given mystmd's active development pace, this is a multi-hour task per release.

**Risk:** Low once working (imports are removed at source, no runtime errors), but high setup risk (build-graph changes could break non-obvious features).

**Go/no-go:** No-go as primary or fallback. Keep as safety-net only for the (unlikely) scenario where post-build prune is blocked by unconditional imports AND a zero-runtime site is critical. For the DSM book project's current minimal-maintenance requirement, the maint. cost alone disqualifies this.

## Comparison

| Option | Size reduction | Impl. cost | Maint. cost | Risk | Rank |
|--------|----------------|------------|-------------|------|------|
| 1 (theme flag) | 0 MB (not feasible) | 0 | 0 | N/A | 3 (n/a) |
| 2 (post-build prune) | 22 MB (31 %) | ~5 LOC YAML | Low (re-verify on mystmd major bump) | Medium (unconditional imports would cause console errors) | **1** |
| 3 (theme fork) | 22 MB (31 %) | 4-8 h | High (per-release sync burden) | Low runtime, high setup | 2 (safety-net) |

## Recommendation

**Primary: Option 2 (post-build prune).** Add a workflow step between `myst build` and `upload-pages-artifact` that runs `find`-based deletes on `*plotly*.js` and `*thebe*.js`/`*thebe*.css`. Size reduction ~22 MB uncompressed (31 %), ~5 lines of YAML, negligible ongoing maintenance. Risk is bounded and has a clear test plan (open the pruned site, check browser console for errors).

**Fallback: the risk-mitigated Option 2.** If post-prune validation finds console errors from unconditional imports, narrow the prune to just plotly files first (18 MB savings, lower blast radius). Thebe is only 4 MB and carries higher integration risk; deferring it to a second pass is a reasonable backoff.

**Safety-net: Option 3 (theme fork).** Do NOT pursue unless Option 2 is blocked entirely. The maint. cost is disproportionate to the 22 MB saved on a site that is already sub-site-generator-median size.

**What NOT to do:** do not wait for an upstream `disable_thebe` flag. No such flag exists, and there's no signal it's planned. Option 2 is actionable now.

## Scope estimate for BACKLOG-004

**Files touched (expected 2):**

- `.github/workflows/scheduled-build.yml` , add one step after `myst build`, before `upload-pages-artifact`. Runs the prune and a `du -sh book/_build/html/` before-and-after measurement logged to the run summary.
- `dsm-docs/plans/BACKLOG-004_artifact-prune.md` , the BL itself (Template 4).

**Lines of code:** ~15 YAML lines + ~5 echo lines for measurement. Well under a 50-LOC ceiling.

**Testing protocol:**

1. Run the updated workflow via `workflow_dispatch` with `force: true`.
2. Download the resulting artifact, `du -sh` to verify size reduction in the expected range (~50 MB uncompressed, ~11 MB zipped). Tolerance: ±2 MB.
3. Open the deployed site in a browser. Check:
   - Index page loads without errors (browser console open).
   - A representative DSM page (e.g., `DSM_0.0_START_HERE_*.html`) loads and renders correctly.
   - Search works.
   - Navigation (prev/next, TOC) works.
   - Network tab shows no failed requests for `*plotly*` or `*thebe*` (the theme must not try to fetch them).
4. If any check fails, revert the workflow change and fall back to the narrower (plotly-only) prune.

**Rollback path:** single-commit revert of the workflow file. No data loss, no migration. Next build reverts to the 72 MB artifact.

**Acceptance criteria sketch:**

- Scheduled + dispatch build both produce artifacts ≤ 12 MB zipped / ≤ 55 MB uncompressed.
- Deployed site passes the manual checks above.
- `dsm-docs/checkpoints/` gets a BL-004 close checkpoint with before/after numbers.

**Non-goals:**

- Pruning the ~45 MB framework chunk bundle (MyST/React/Remix). Out of scope for BL-004; would be a separate research BL with much higher risk.
- Modifying mystmd's build pipeline upstream. Upstream option would be welcome but not on our critical path.

## Open questions

- Does the MyST `book-theme` template expose an option to disable the thebe runtime, or is thebe unconditionally included?
- Are plotly imports in the build eager (always included) or lazy (only if a `{plotly}` block is present)?
- What is the actual wire-size of each runtime (plotly.min.js, thebe.min.js, chunk files)?
- Does the build-time flag for mystmd (if any exists) affect search index quality or only the HTML payload?

## Session log

- **Session 5 (2026-04-19):** File created as Phase C kickoff, skeleton only. Evidence gathering deferred to next Sprint 2 session.
- **Session 6 (2026-04-20):** Research complete in one session. Evidence gathering: downloaded artifact 6525506268 (run 24652216077, first scheduled fire). Populated Artifact breakdown with per-pattern and top-15-file measurements. Corpus audit confirmed zero executable-content directives across 43 DSM_*.md files. S4's plotly+thebe quantification confirmed (22.26 MB); S4's "~90 % reduction" claim corrected to 31 % (chunk bundle accounts for the remaining ~45 MB). Option inventory: Option 1 (theme flag) documented as negative finding after searching mystmd.org/guide/website-templates, mystmd.org/guide/execute-notebooks, mystmd.org/thebe/options, and myst-theme docs/ui.md; no opt-out flag exists in mystmd v1.8.3 / book-theme current. Option 2 (post-build prune) documented with ~5 LOC YAML mechanism, 22 MB savings, medium risk (unconditional-import failure mode), test plan. Option 3 (theme fork) documented as safety-net only (high maint. cost). Recommendation: Option 2 primary, risk-mitigated Option 2 (plotly-only) fallback. Scope estimate for BL-004 drafted.
