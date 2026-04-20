# BACKLOG-004: Artifact Prune (plotly + thebe runtime removal)

**Status:** Draft (pending approval)
**Priority:** Medium
**Date Created:** 2026-04-20
**Origin:** Sprint 2 BACKLOG-003 Phase C research (`dsm-docs/research/2026-04-19_artifact-bloat_research.md`)
**Author:** Alberto Diaz Durana

---

## Goal

Reduce the deployed GitHub Pages artifact by ~22 MB (31 %) by stripping the
`plotly` and `thebe` JS/CSS bundles that the mystmd `book-theme` unconditionally
includes but that the prose-only DSM corpus does not use.

Result target: artifact drops from ~72 MB uncompressed / ~15.5 MB zipped to
~50 MB uncompressed / ~11 MB zipped.

## Background

Phase C research audited artifact 6525506268 (first scheduled fire, run
24652216077, 2026-04-20T06:39:39Z) and found:

- Total uncompressed: 72 MB (93 % in `build/_shared/`)
- Plotly: 18.43 MB (25.6 %), 2 bundle variants
- Thebe: 3.83 MB (5.3 %), ~30 files
- Unnamed framework chunks: 35.32 MB (49.1 %), MyST/React/Remix
- Corpus: zero executable-content directives across 43 DSM_*.md files

Option inventory concluded:

- No mystmd flag exists to exclude thebe/plotly from the bundle (verified across 4 doc surfaces).
- Theme fork is disproportionate maintenance cost for a 22 MB win.
- Post-build prune is the low-cost, tractable path.

Full rationale: `dsm-docs/research/2026-04-19_artifact-bloat_research.md`.

## Scope

1. Add one workflow step to `.github/workflows/scheduled-build.yml`, after
   `myst build` and before `actions/upload-pages-artifact`, that:
   - Reports `du -sh book/_build/html/` before prune
   - Runs `find book/_build/html -name '*plotly*.js' -delete`
   - Runs `find book/_build/html \( -name '*thebe*.js' -o -name '*thebe*.css' \) -delete`
   - Reports `du -sh book/_build/html/` after prune
   - Emits both measurements to `$GITHUB_STEP_SUMMARY`
2. Trigger a `workflow_dispatch --force` run to produce a pruned artifact.
3. Manual browser validation against the deployed pruned site (see Acceptance criteria).
4. If validation passes: merge, record run ID + before/after sizes in a
   closure checkpoint.
5. If validation fails with plotly+thebe both pruned: narrow to plotly-only
   (drop the thebe delete line), re-dispatch, re-validate. If validation
   passes narrowed: document and merge the narrower version. If still fails:
   revert and file a follow-up research BL.

## Acceptance criteria

1. Pruned artifact ≤ 12 MB zipped / ≤ 55 MB uncompressed (tolerance ±2 MB
   on the uncompressed figure).
2. Deployed pruned site passes these manual checks in a browser:
   - Index page loads with no console errors
   - A representative DSM page (e.g., `DSM_0.0_START_HERE`) loads and renders
     correctly
   - Search works and returns expected results
   - Prev/next and TOC navigation works
   - Network tab shows no failed `*plotly*` or `*thebe*` requests (theme
     must not try to fetch them)
3. Scheduled daily build (Phase A) continues to complete green after the
   change.
4. A closure checkpoint in `dsm-docs/checkpoints/` records:
   - Before/after artifact sizes (zipped + uncompressed)
   - Run ID of the validation dispatch run
   - Browser-check outcome
   - Any deviations from the primary plan (e.g., fell back to plotly-only)

## Risk and mitigation

**Risk 1: Framework chunks import plotly/thebe unconditionally.** Deletion
causes a browser JS error when the chunk executes, even on prose-only pages.
**Mitigation:** post-prune validation is mandatory; if errors occur, the
step 5 fallback (plotly-only) reduces the blast radius. Plotly is 18 MB of
the 22 MB; the 4 MB thebe-only case is acceptable if it protects site function.

**Risk 2: mystmd version bump changes the bundle file-name pattern.** The
`*plotly*` / `*thebe*` globs are stable across current minor versions but
a major bump (e.g., renaming to `runtime-plotly-*`) would silently stop
matching. **Mitigation:** on any mystmd version bump, a pre-push local
build + `ls book/_build/html` check verifies the patterns still catch the
bundle files. If the patterns miss, re-run the research to find new names.

**Risk 3: Pruning silently reduces site functionality (e.g., a feature that
uses plotly/thebe without a live block).** **Mitigation:** the corpus audit
ruled this out for the current DSM corpus (zero executable directives). If
a future DSM document adds executable content, this BL must be revisited.

## Rollback path

Single-commit revert of `.github/workflows/scheduled-build.yml`. No data
loss, no migration. The next build reverts to the 72 MB artifact.

## Out of scope

- Pruning the ~45 MB framework chunk bundle (MyST/React/Remix). Higher risk,
  higher complexity, belongs in a separate research BL if pursued.
- Forking `@myst-theme/book-theme`.
- Opening an upstream mystmd issue for a first-class opt-out flag. (Welcome
  but not on our critical path; if desired, file as a low-priority follow-up.)

## Dependencies

- Phase A (Sprint 2 Item A) stable: scheduled daily build confirmed green on
  2026-04-20 at 06:39:39Z, run 24652216077.
- `take-ai-bite` upstream prose-only corpus. If upstream adds executable
  content, this BL must be re-evaluated (see Risk 3).

## References

- Research: `dsm-docs/research/2026-04-19_artifact-bloat_research.md`
- Sprint plan: `dsm-docs/plans/BACKLOG-003_sprint-2-implementation.md` (Item C)
- Sprint 1 closure: `dsm-docs/checkpoints/done/2026-04-19_s4_sprint-1-close.md`
  (H measurements)

## Estimate

- Implementation: ~15 LOC YAML in one file. 15-30 min.
- Validation: 10-15 min manual browser checks + run-download + `du -sh`.
- Closure checkpoint: 5 min.
- **Total: ~45-60 min in a single session.**
