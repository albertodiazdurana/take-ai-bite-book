# Phase B drift reporting , simulation evidence (Session 6)

**Date:** 2026-04-20
**Session:** 6
**Sprint:** 2 (BACKLOG-003)
**Phase:** B (Version-drift reporting)

## Context

Phase B adds drift-aware reporting to `scheduled-build.yml` via `$GITHUB_STEP_SUMMARY`. Live testing on the sprint-2 branch failed: the `github-pages` environment is pinned to `main`, so `workflow_dispatch --ref sprint-2/...` is rejected at startup (run 24664805194 failed in 2 seconds, zero steps executed). This means the Check step never ran and no step summary could be captured from a real workflow run on the feature branch.

Rather than polluting `main` with a synthetic drift marker (option B2) or temporarily relaxing the environment policy (B3, reversible but a real risk window), Phase B evidence was captured via **local shell simulation** of the Check step logic. This is the "synthetic drift run" half of the sprint plan exit criterion.

## Simulation

The Check step shell logic was extracted into a function and exercised with four synthetic input sets covering all branches of the control flow:

| Case | `LAST_BUILT` | `LATEST` | `rc` | `force` | Expected `DRIFT_STATE` | Expected `REBUILD_REASON` |
|---|---|---|---|---|---|---|
| 1 | `(none)` | `v1.5.4` | 10 | false | INITIAL BUILD | new tag available |
| 2 | `v1.5.4` | `v1.5.4` | 0 | false | IN SYNC | in sync, no rebuild |
| 3 | `v1.5.3` | `v1.5.4` | 10 | false | DRIFTED (v1.5.3 -> v1.5.4) | new tag available |
| 4 | `v1.5.4` | `v1.5.4` | 0 | true | IN SYNC | forced (workflow_dispatch force=true) |

## Results

### Case 1: INITIAL BUILD

```
GITHUB_OUTPUT:
  rebuild=true
  tag=v1.5.4

GITHUB_STEP_SUMMARY:
  ## take-ai-bite sync status

  | Field | Value |
  |---|---|
  | Last built version | `(none)` |
  | Latest upstream tag | `v1.5.4` |
  | Rebuild this run | new tag available |
  | Tag being built | `v1.5.4` |

  **Drift state:** INITIAL BUILD
```

Pass. First-build case handled without false-positive drift alarm.

### Case 2: IN SYNC

```
GITHUB_OUTPUT:
  rebuild=false

GITHUB_STEP_SUMMARY:
  ## take-ai-bite sync status

  | Field | Value |
  |---|---|
  | Last built version | `v1.5.4` |
  | Latest upstream tag | `v1.5.4` |
  | Rebuild this run | in sync, no rebuild |
  | Tag being built | , (no rebuild) |

  **Drift state:** IN SYNC
```

Pass. No-drift path reports IN SYNC without alarm, rebuild skipped correctly.

### Case 3: DRIFTED

```
GITHUB_OUTPUT:
  rebuild=true
  tag=v1.5.4

GITHUB_STEP_SUMMARY:
  ## take-ai-bite sync status

  | Field | Value |
  |---|---|
  | Last built version | `v1.5.3` |
  | Latest upstream tag | `v1.5.4` |
  | Rebuild this run | new tag available |
  | Tag being built | `v1.5.4` |

  **Drift state:** DRIFTED (v1.5.3 -> v1.5.4)
```

**Pass. DRIFTED state reports both values with direction arrow, rebuild is triggered.** This is the S4 feedback case ("v1.5.3 target, v1.5.4 built, not surfaced"), now surfaced.

### Case 4: IN SYNC + FORCE

```
GITHUB_OUTPUT:
  rebuild=true
  tag=v1.5.4

GITHUB_STEP_SUMMARY:
  ## take-ai-bite sync status

  | Field | Value |
  |---|---|
  | Last built version | `v1.5.4` |
  | Latest upstream tag | `v1.5.4` |
  | Rebuild this run | forced (workflow_dispatch force=true) |
  | Tag being built | `v1.5.4` |

  **Drift state:** IN SYNC
```

Pass. Force-dispatch path rebuilds on-demand while correctly reporting IN SYNC (no real drift; force was user intent).

## Exit criterion mapping

Sprint 2 plan Phase B exit criterion:

> "Phase B closes when: drift is visible on the chosen surface during a live or synthetic drift run, and the no-drift path stays silent."

| Half | Evidence |
|---|---|
| Drift is visible | Case 3 output above. `**Drift state:** DRIFTED (v1.5.3 -> v1.5.4)` is visible in the summary with full before/after tag values. |
| No-drift path stays silent | Case 2 output above. `**Drift state:** IN SYNC` is non-alarming, no warning-styled formatting, no background color, no emoji. Plain markdown table + state line. |

Supplementary: Case 1 (INITIAL BUILD) and Case 4 (forced rebuild) exercise the two remaining REBUILD_REASON paths not strictly required by the exit criterion, confirming the full logic works.

## Live-run follow-up

The live IN SYNC path will be exercised when sprint-2 is merged to main and a `workflow_dispatch --ref main` is issued (or naturally by the next scheduled cron fire at 06:00 UTC). Current `main` state: `.last-built-version=v1.5.4`, upstream latest=v1.5.4; first real run after merge is expected to match Case 2 output.

## Reproduction

Extract the Check step's shell logic from `.github/workflows/scheduled-build.yml` into a function (see session transcript appendix), call with each (LAST_BUILT, LATEST, rc, force) tuple above, inspect `/tmp/gh_summary_test` after each call.

No test script is committed to the repo; the simulation is a one-shot verification, not production test infrastructure. If the Check step logic changes significantly in a future sprint, re-run the simulation before merging.
