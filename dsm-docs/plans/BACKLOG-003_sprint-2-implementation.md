# BACKLOG-003: Sprint 2 — Scheduled Builds, Drift Reporting, Artifact Research

**Status:** In progress
**Priority:** High
**Date Created:** 2026-04-19
**Origin:** Sprint 1 closure checkpoint (`dsm-docs/checkpoints/done/2026-04-19_s4_sprint-1-close.md`, "Next steps (Sprint 2)" section)
**Author:** Alberto Diaz Durana

## Goal

Take the pipeline from "manual trigger, first green build" (Sprint 1 state) to "daily scheduled builds, drift-aware reporting, and evidence-backed plan for artifact-size reduction."

## Duration

No target count or calendar bound. Scope-bounded: sprint closes when all exit criteria are met.

## Prerequisites

- Sprint 1 closed, site live at v1.5.4: https://albertodiazdurana.github.io/take-ai-bite-book/
- `scheduled-build.yml` present on main with a commented `schedule:` stanza at lines 41-42
- `scripts/inject-version.sh`, `scripts/check-upstream-version.sh`, `scripts/copy-upstream-content.sh` present and tested in Sprint 1
- `dsm-docs/research/` folder exists with Sprint 1 research files in `done/`
- `github-pages` environment branch-policy pinned to main (fixed during Sprint 1)

## Research Assessment

Per DSM_2.0.C Template 8 §Research Assessment. Evaluation of Phase 0.5 need for each work item:

| Item | Needs research? | Why |
|------|-----------------|-----|
| A (cron activation) | **No** | Stanza already drafted; GitHub Actions scheduled-workflow mechanics exercised during Sprint 1 debugging (registration + env-policy gates are the only risks, both fixed). |
| B (drift reporting) | **No** | Surface choice (workflow summary / footer / wrap-up) is a design decision, not a research question. Will be locked during implementation. |
| C (artifact-bloat) | **Yes, required** | MyST theme internals, executable-content runtime flags, post-build prune alternatives are all unknowns. Implementation cannot start without evidence. Phase 0.5 research file is Item C's deliverable for this sprint. |

## Deliverables

1. Active scheduled cron in `scheduled-build.yml` on main, with at least one successful auto-triggered green build in the Actions log.
2. Version-drift surface: when `force=true` (or steady-state) resolves a tag newer than the last-built-version, the drift is visible in at least one of: workflow step summary, injected footer, README badge, or wrap-up output. Surface location selected during Item B.
3. Research file `dsm-docs/research/YYYY-MM-DD_artifact-bloat_research.md` with: evidence of current bloat sources (sizes by runtime), inventory of MyST theme/plugin flags for disabling executable-content runtimes, post-build prune alternatives, recommendation + scope estimate for the implementation BL.

## Exit criteria

Sprint 2 is done when all of these are true:

1. Cron stanza uncommented in `scheduled-build.yml`, committed to main, and one auto-triggered green run exists in the Actions log (no manual `workflow_dispatch` trigger).
2. Version-drift reporting implemented and exercised at least once (either against a real drift or via a forced test).
3. Artifact-bloat research file in `dsm-docs/research/` with header (Purpose, Target Outcome, Status) and the three required content sections (evidence, inventory, recommendation + scope estimate).
4. Follow-up BL (BACKLOG-004) created for artifact-strip implementation, informed by Item C research findings; BACKLOG-004 lives in `dsm-docs/plans/` and references Item C.
5. Wrap-up completed: checkpoint written, MEMORY.md updated, feedback files pushed to DSM Central, blog journal entry appended.

## Branch strategy

- Sprint branch: `sprint-2/YYYY-MM-DD` off main (YYYY-MM-DD = date of first Sprint 2 session).
- Session branches for work inside Sprint 2 base off `sprint-2/...`, not main.
- PR to main at sprint close with explicit `--base main`, verified via `gh pr view` before merge (Check B discipline from S4 feedback).

## Phases (ordered by dependency, parallel where noted)

### Phase A — Cron activation

1. Cut `sprint-2/YYYY-MM-DD` from main.
2. Uncomment the schedule stanza in `scheduled-build.yml` (remove the `# Sprint 2: uncomment to activate daily polling.` comment line and the `# ` prefix on the two stanza lines).
3. Commit on sprint-2 branch. Push.
4. Open PR to main with `--base main`, verify base via `gh pr view`, merge.
5. Wait for the next scheduled fire (`06:00 UTC`).
6. Inspect the auto-triggered run in the Actions log. Confirm conclusion=success.
7. Record run ID + wall time in the Phase A closure notes.

**Phase A closes when:** one auto-triggered green run exists.

### Phase B — Version-drift reporting

Can run in parallel with Phase A after the sprint-2 branch is cut (Step 1 of Phase A).

1. Decide drift surface. Default candidates:
   - **Workflow step summary** (`$GITHUB_STEP_SUMMARY`) with a drift block if `resolved_tag != plan_target` or `resolved_tag != last_built_version` in force-path.
   - **Injected footer** — augment `scripts/inject-version.sh` to add a "drift" marker if the resolved tag exceeds a recorded sprint-target.
   - **README badge** or build log line — lighter touch.
2. Implement the selected surface. Keep scope minimal.
3. Test via a forced rebuild (or synthetic drift via a stashed `.last-built-version`).
4. Verify drift shows on the chosen surface, no-drift state remains silent.

**Phase B closes when:** drift is visible on the chosen surface during a live or synthetic drift run, and the no-drift path stays silent.

### Phase C — Artifact-bloat research

Can run in parallel with Phases A and B. Phase C is research-only; no code changes.

1. Inspect the deployed Pages artifact (uncompressed 68 MB, zipped 15 MB per S4 checkpoint). Break down sizes by subfolder / file pattern. Confirm plotly + thebe account for ~90% of payload as hypothesized.
2. Inventory `myst.yml` / MyST theme flags for disabling executable-content runtimes. Read mystmd docs + the active theme's source.
3. Inventory post-build prune alternatives: shell-level deletions of unused JS chunks, `find … -delete` patterns, theme fork with removed plugins.
4. Compare options on: implementation cost, maintenance cost (upstream theme updates), risk of breaking legitimate in-corpus usage.
5. Write `dsm-docs/research/YYYY-MM-DD_artifact-bloat_research.md` with evidence, inventory, comparison, and a recommendation + scope estimate for the implementation BL.
6. Spawn BACKLOG-004 (artifact-strip implementation) referencing the research file.

**Phase C closes when:** research file is complete (Status: Done in header) and BACKLOG-004 is created in `dsm-docs/plans/`.

## Out of scope

- **Artifact-strip implementation.** Spawned as BACKLOG-004 during Phase C closure. Implementation refined in a future sprint based on Sprint 2 research + any A/B learnings.
- Pages-deploy optimizations (caching, redirect rules, custom domain, compression settings).
- Theme customization beyond what Phase C research recommends.
- Scheduled-build retries, notification on failure, or alerting infrastructure.

## Sprint 3 hint (not this sprint)

Artifact-strip implementation (BACKLOG-004) informed by Item C research. May also absorb refinements surfaced by live cron runs in Phase A or drift-reporting edge cases in Phase B.

## Phase Boundary Checklist

At the close of each phase (A, B, or C), before moving to the next phase or Sprint-level wrap:

- [ ] Phase's "closes when" condition met and evidenced (run ID, filename, or screenshot in Phase closure notes)
- [ ] Phase's commits pushed to sprint-2 branch
- [ ] Phase-specific risks and open issues logged in the plan's Risks or Open Issues section
- [ ] Any new backlog items surfaced during the phase captured in `dsm-docs/plans/` or `_inbox/`

## Sprint Boundary Checklist

At Sprint 2 close:

- [ ] All 3 exit criteria met and evidenced
- [ ] BACKLOG-004 created and present in `dsm-docs/plans/`
- [ ] Sprint 2 closure checkpoint written in `dsm-docs/checkpoints/` covering: outcome summary, exit-criteria evidence, surprises, follow-up BLs, branch state
- [ ] Blog journal entry appended to `dsm-docs/blog/journal.md`
- [ ] Feedback files for DSM Central (if any observations from Sprint 2) in `dsm-docs/feedback-to-dsm/` and pushed to Central inbox
- [ ] MEMORY.md "Latest Session" and "Pending for next session" updated
- [ ] sprint-2 PR to main merged with explicit `--base main`, verified via `gh pr view` before merge
- [ ] Sprint 1 plan moved from `dsm-docs/plans/done/` position confirmed (stays in done/, already there); Sprint 2 plan moved to `dsm-docs/plans/done/`

## Risks

- **Cron non-fire on first scheduled window.** GitHub's scheduled-workflow indexer has a known propagation delay after a workflow-file change. If the first 06:00 UTC window passes without a run, re-verify registration via `gh workflow list` and `gh workflow view scheduled-build.yml`. Manual `workflow_dispatch` does not substitute for the exit criterion.
- **Research inconclusive on Item C.** If no clean MyST-level disable path exists and post-build prune is fragile, BACKLOG-004 may land as a theme-fork proposal instead of a prune proposal. Acceptable; the research deliverable is the finding, not a guaranteed fix path.
- **Version-drift surface bikeshed.** Risk of spending too long on surface choice. Mitigation: default to workflow step summary (lowest-cost surface) unless a clear reason to prefer footer or badge emerges.

## How to Resume

If a session ends mid-sprint:

1. Check `git branch --show-current`. If on `sprint-2/...`, resume; if on a `session-N/...` branch, check its parent.
2. Read this plan's "Phases" section. Identify which phase is in flight by `git log sprint-2/... --oneline | head -10`.
3. Read the Sprint 1 closure checkpoint (in `dsm-docs/checkpoints/done/`) for context on pipeline internals.
4. Open `.github/workflows/scheduled-build.yml` and check: is schedule stanza uncommented and on main? If yes → Phase A is complete or waiting for cron fire.
5. Check `dsm-docs/research/` for an in-progress artifact-bloat research file.

## Notes

- Phase A has a one-way-door moment: once the cron is committed to main, it fires every day until disabled. Silent failures could accumulate. Phase A's exit criterion requires **one** green auto-triggered run as proof; ongoing health should be monitored via the Actions tab during Sprint 2, and any flake noted here.
- Feedback from S4 flagged the version-drift silence (v1.5.3 target, v1.5.4 built, not surfaced). Phase B's exit criterion exercises this specifically.
- S4 surfaced three permission/agent-discipline feedback items (see `dsm-docs/feedback-to-dsm/done/`). Sprint 2 should apply the Check-B PR-base verification discipline on every `gh pr create` without exception.

## Open issues

- None at sprint-plan creation. Will be appended here as they surface during phases.
