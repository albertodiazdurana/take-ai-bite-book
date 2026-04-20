# Sprint 3: Artifact prune (BL-004)

**Status:** Active
**Priority:** Medium
**Date Created:** 2026-04-20
**Origin:** Sprint 2 Phase C research (`dsm-docs/research/2026-04-19_artifact-bloat_research.md`), BL-004 activation
**Author:** Alberto Diaz Durana

---

**Duration:** 1 session, ~45-60 min (matches BL-004 estimate)

**Goal:** Deploy a pruned GitHub Pages artifact with `plotly` and `thebe` JS/CSS bundles removed, validate in a live browser, and lock the saving. Target: artifact drops from ~72 MB uncompressed / ~15.5 MB zipped to ≤55 MB uncompressed / ≤12 MB zipped.

**Prerequisites:**

- Phase A cron stable (confirmed green 2026-04-20T06:39:39Z, run 24652216077).
- BL-004 (`dsm-docs/plans/BACKLOG-004_artifact-prune.md`) Draft -> Active as of this sprint activation.
- `main` clean (Sprint 2 merged via PRs #7, #8, #9; B5 IN SYNC verified via run 24667001786).

## Research Assessment

Phase C research (`dsm-docs/research/2026-04-19_artifact-bloat_research.md`) is Complete. Three gates cleared:

1. **Evidence gathered.** Artifact 6525506268 (scheduled fire 2026-04-20) audited: 72 MB uncompressed, plotly 18.43 MB (25.6 %), thebe 3.83 MB (5.3 %), framework chunks 35.32 MB (49.1 %). Corpus has zero executable-content directives across 43 DSM_*.md files.
2. **Option inventory done.** mystmd opt-out flag: does not exist (verified across 4 doc surfaces). Theme fork: disproportionate cost. Post-build prune: tractable, ~15 LOC YAML, manual validation.
3. **Recommendation fixed.** Option 2 (post-build prune, plotly + thebe). Rollback is single-commit revert.

No new research required before implementation.

## Deliverables

| Item | Description | BL-004 mapping |
|------|-------------|----------------|
| A | Workflow YAML prune step added to `.github/workflows/scheduled-build.yml` with before/after size reporting to `$GITHUB_STEP_SUMMARY` | Scope 1, 2 |
| B | Live `workflow_dispatch --force=true` run after merge, artifact downloaded, before/after sizes captured | Scope 3, Acceptance 1 |
| C | Closure checkpoint in `dsm-docs/checkpoints/` recording sizes, run ID, browser outcome, any fallback path taken | Acceptance 4 |

## Phases (ordered)

### Phase A , Implement prune step

1. Cut `sprint-3/2026-04-20` off `session-7/2026-04-20`.
2. Add a new workflow step named `Prune theme-bundled runtime (plotly + thebe)` placed AFTER `Build HTML` and BEFORE `Upload Pages artifact` in `.github/workflows/scheduled-build.yml`.
3. The step does: `du -sh book/_build/html/` (before), `find book/_build/html -name '*plotly*.js' -delete`, `find book/_build/html \( -name '*thebe*.js' -o -name '*thebe*.css' \) -delete`, `du -sh book/_build/html/` (after), emit both measurements to `$GITHUB_STEP_SUMMARY` under a `## Artifact prune` heading.
4. The step is guarded by `if: steps.check.outputs.rebuild_flag == 'true'` so the no-rebuild (IN SYNC) path stays silent and skips the prune.
5. Commit on `sprint-3/2026-04-20` with a descriptive message referencing BL-004 scope items 1-2.
6. Open PR to main with explicit `--base main`, verify via `gh pr view` before merge (Check B discipline).

**Phase A closes when:** prune step committed, PR opened with verified `--base main`, merged.

### Phase B , Validation dispatch

1. On `main`, run `gh workflow run scheduled-build.yml --ref main -f force=true`.
2. Wait for completion (~3-4 min based on Sprint 2 timings; add ~10-20 s for the new step). Track the run ID.
3. Confirm `conclusion=success`. Inspect the `## Artifact prune` summary block for before/after sizes.
4. Download the `github-pages` artifact via `gh run download <run-id>`; run `du -sh` on the uncompressed content to cross-check against the summary.
5. Verify the zipped artifact size from the workflow summary is ≤ 12 MB (±1 MB tolerance).

**Phase B closes when:** force=true run is green, before/after sizes captured, both zipped and uncompressed figures recorded.

### Phase C , Browser validation

1. Open the deployed site (https://albertodiazdurana.github.io/take-ai-bite-book) in a browser with DevTools open.
2. Hard-refresh. Verify the index page loads with no JS console errors.
3. Navigate to a representative DSM page (e.g., `DSM_0.0_START_HERE` or any concrete page from the left nav). Confirm it renders.
4. Run a search for a known term (e.g., "DSM"). Confirm results return as expected.
5. Exercise prev/next navigation and at least 2 TOC clicks. Confirm all target pages load.
6. Inspect the Network tab across the checks in steps 2-5. Confirm zero failed requests matching `*plotly*` or `*thebe*` (theme must not attempt to fetch the pruned files).

**Phase C closes when:** all 6 checks pass. **Fallback path:** if any check fails AND the failure is traceable to plotly or thebe, narrow the Phase A step to plotly-only (remove the thebe delete line), re-run Phases A-C. If validation still fails, revert the prune step entirely and file a research follow-up BL.

## Phase Boundary Checklist

- [ ] Phase A closed: prune step committed on sprint-3, PR merged with verified `--base main`.
- [ ] Phase B closed: force=true dispatch green, before/after sizes recorded.
- [ ] Phase C closed: all 6 browser checks pass OR narrowed plotly-only path validated.

## Sprint Boundary Checklist

- [ ] Closure checkpoint written at `dsm-docs/checkpoints/2026-MM-DD_s{N}_sprint-3-close.md` covering sizes, run ID, browser outcome, any fallback.
- [ ] BL-004 moved to `dsm-docs/plans/done/` with Status: Done, Date Completed: YYYY-MM-DD, closure annotation (run ID + sizes + browser outcome).
- [ ] BL-005 (this file) moved to `dsm-docs/plans/done/`.
- [ ] `dsm-docs/plans/README.md` index updated.
- [ ] MEMORY.md Sprint 3 section: outcome, sizes, surprises, pending items.
- [ ] Blog journal entry in `dsm-docs/blog/journal.md` with 2026-MM-DD date.
- [ ] Feedback files filed if any methodology observations emerged (per-session format).
- [ ] Follow-up BLs created, if any (e.g., mystmd major-version drift check per BL-004 Risk 2, framework-chunk reduction research).

## Surprises

, to be filled during execution.

## Closure notes

, to be filled at sprint close.
