# Sprint 2 closure checkpoint

**Date:** 2026-04-20
**Session:** 6
**Sprint:** 2 (BACKLOG-003)
**Outcome:** All exit criteria met. Sprint 2 closed.

## Outcome summary

Sprint 2 took the pipeline from "manual trigger, first green build" (Sprint 1 state) to "daily scheduled builds, drift-aware reporting, and evidence-backed plan for artifact-size reduction."

Three items delivered in two sessions (S5 + S6):

| Item | Delivered | Sprint-plan exit criterion |
|---|---|---|
| A , cron activation | PR #6 merged 2026-04-19, first scheduled fire 2026-04-20T06:39:39Z (run 24652216077, green) | 1 , auto-triggered green run exists |
| B , drift reporting | `$GITHUB_STEP_SUMMARY` table with 4 rows + drift-state classifier, shell-simulation evidence across 4 cases | 2 , drift visible during real or synthetic run |
| C , artifact-bloat research | Research file complete with evidence, options, recommendation, scope estimate | 3 , research file with 3 required sections |
| BL-004 follow-up | Created, Draft, Medium priority | 4 , BL-004 in `dsm-docs/plans/` referencing Item C |
| Wrap-up | This checkpoint, MEMORY update, feedback files, blog entry, PR merge | 5 , wrap-up complete |

## Exit-criteria evidence

1. **Auto-triggered green run:** `gh api repos/albertodiazdurana/take-ai-bite-book/actions/runs/24652216077` returns `event=schedule, conclusion=success, started 2026-04-20T06:39:39Z`. Artifact 6525506268 (15.47 MB zipped).
2. **Drift reporting:** `dsm-docs/checkpoints/2026-04-20_s6_phase-b-drift-simulation.md` captures output for INITIAL / IN SYNC / DRIFTED / IN SYNC+FORCE cases. Case 3 (DRIFTED v1.5.3 -> v1.5.4) exactly reproduces the S4 feedback scenario, now visible.
3. **Research file:** `dsm-docs/research/2026-04-19_artifact-bloat_research.md`, Status: Complete. All four TBD sections populated (evidence, option inventory, comparison, recommendation + scope).
4. **BL-004:** `dsm-docs/plans/BACKLOG-004_artifact-prune.md`, Draft, Medium, with full scope + risks + rollback.
5. **Wrap-up:** in progress as this checkpoint is written.

## Surprises (also in sprint plan Surprises section)

- GitHub environment-branch policy blocks feature-branch dispatch at job startup, not between steps. Invalidated the "run synthetic drift on sprint-2, accept Deploy failure" approach. Workaround: local shell simulation.
- First scheduled fire was ~40 min past the nominal 06:00 UTC window. GitHub cron best-effort behavior is known; this just documented the specific delay for the project.
- S4's "~90 % plotly+thebe" hypothesis was wrong; real number is 31 %. Caught before it influenced BL-004 sizing.

## Branch state at closure

- `sprint-2/2026-04-19` holds Sprint 2 deliverables + closure commits. To be merged to `main` via PR before Sprint 2 is formally closed.
- `.last-built-version=v1.5.4` (synthetic drift test was reverted on sprint-2; site deploys remain at v1.5.4).
- One PR to open: sprint-2 -> main, with Phase B + C + BL-004 + closure commits.

## Next sprint preview

Sprint 3 natural candidates (not this sprint's scope):

- BACKLOG-004 implementation (post-build prune of plotly + thebe).
- Ongoing cron-fire observation: watch for delay outliers, silent failures, or authentication expiries over the next 30-60 days.
- Optional: explore MyST framework chunk reduction if BL-004's 22 MB saving proves insufficient (research-heavy, not recommended unless pressing need).

## Follow-up BLs

- BACKLOG-004 (Medium): artifact prune implementation.

## Files committed this session

- `.github/workflows/scheduled-build.yml` (Phase B drift reporting)
- `dsm-docs/research/2026-04-19_artifact-bloat_research.md` (Phase C evidence + options + recommendation)
- `dsm-docs/plans/BACKLOG-004_artifact-prune.md` (new)
- `dsm-docs/plans/README.md` (index update)
- `dsm-docs/plans/BACKLOG-003_sprint-2-implementation.md` (status + closure notes)
- `dsm-docs/checkpoints/2026-04-20_s6_phase-b-drift-simulation.md` (new, Phase B evidence)
- `dsm-docs/checkpoints/2026-04-20_s6_sprint-2-close.md` (this file, Sprint 2 closure)
- `dsm-docs/blog/journal.md` (Sprint 2 closure entry)

## STAA recommendation for Session 6

**Maybe.** S6 had two non-trivial course corrections worth recording:

1. The B1 test approach failed due to mis-modeling the environment-policy gate (assumed "between steps", actual "before any step"). Course-corrected to B4 local simulation. Reasoning-worthy: how and when to probe platform-gating behavior before committing to a test plan.
2. Phase B Gate 2 diff had a brittle `cat GITHUB_OUTPUT | grep` re-read that would have worked on GitHub but broke good shell hygiene. Caught and fixed during implementation (switched to REBUILD_FLAG local var). Reasoning-worthy: when NOT to rely on runner-injected files within the same step.

Both are extractable lessons, neither is a deep cascade. `/dsm-staa` at the user's discretion.
