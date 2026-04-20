# Methodology feedback , Session 6 (2026-04-20)

Per-session methodology observations from dsm-jupyter-book Sprint 2 closure.

## Observation 1: environment-gating blocks feature-branch testing of deploy workflows

**Score:** 7/10 (pattern worth codifying)

**What happened.** Sprint 2 Phase B aimed to exercise a drift-reporting addition to a GitHub Actions workflow that deploys to GitHub Pages. The `github-pages` environment has a branch-protection policy restricting deploys to `main`. I attempted to run a synthetic-drift test on the feature branch, expecting the Check step (which writes the drift summary to `$GITHUB_STEP_SUMMARY`) to run even if the later Deploy step was rejected by the environment policy. The job instead failed in 2 seconds at startup with zero steps executed; the environment-policy gate runs *before* any step, not between steps.

**Why this matters for methodology.** The DSM 4.0 App Development Protocol implicitly assumes you can test workflow changes on a feature branch and rely on downstream failures (auth, deploy, environment gating) to surface late without blocking earlier-step verification. This is not true for protected-environment workflows. The test approach has to account for the environment gate running before step execution.

**Proposed codification.** Add a note to DSM_0.2.C (Destructive Action Protocol / Branching Strategy) or DSM 4.0 (App Development Protocol) distinguishing two classes of CI testing:

- **Non-gated workflows:** feature-branch dispatch runs end-to-end; deploy-step failures are localized.
- **Gated-environment workflows:** feature-branch dispatch is rejected at startup; must either (a) relax the environment policy temporarily (risky), (b) merge-then-test on main (pollutes main with test commits), or (c) simulate the step locally (preferred, zero CI risk).

The rule of thumb: if a workflow deploys to a GitHub environment with a branch policy, feature-branch testing defaults to local simulation, not dispatch.

## Observation 2: `gh run list` eventual consistency lagged artifact visibility

**Score:** 5/10 (minor tooling quirk, not actionable)

**What happened.** The first scheduled cron fire was checked ~40 min post-window via `gh run list --event=schedule --limit 10`, returning `[]`. The same moment, `gh api .../actions/artifacts` returned an artifact created 40 s earlier from that exact run. The run clearly existed and had succeeded, but the run-list query didn't see it. Cause likely `gh`'s caching or GitHub's API eventual consistency; switching to the artifacts-first check proved the run existed.

**Methodology takeaway (if any).** When verifying scheduled workflow fires, the artifacts endpoint is a more reliable signal than the run-list endpoint. Low-priority, not worth a protocol change, but worth remembering.

## Observation 3: Pre-Generation Brief Gates 1+2 worked cleanly

**Score:** 9/10 (positive confirmation of protocol value)

**What happened.** Phase B implementation was gated into two explicit approval steps: (1) design brief (surface choice, what to report, exit-criterion mapping), (2) exact diff (YAML change, what's new vs unchanged, validation plan). Each got one-line "approve" responses from the user; the second gate caught one brittle pattern (`cat GITHUB_OUTPUT | grep` re-read within the same step) that the first gate hadn't considered, and I was able to fix it in the implementation without a rework cycle.

**Methodology takeaway.** The 4-gate model adds real value on workflow changes specifically because the workflow runner behavior is not always obvious from the YAML (file writes, step ordering, environment gates). Splitting design (what to report, where to surface) from implementation (exact diff + runner-specific concerns) prevented a rework cycle on the same PR. The user spending 2 turns to approve instead of 1 was cheap insurance.

**No proposal.** Already codified in DSM_0.2 Pre-Generation Brief Protocol. Just a positive data point.

## Observation 4: S4's "Check B" PR-base discipline (BL-386) worked without reminder

**Score:** 8/10 (habit formed)

**What happened.** During this session, two PRs were conceptually available (Sprint 2 deliverable PR, not yet created at the time of this feedback file). The S4 feedback item (verify `--base main` explicitly before merge) did not need to be re-surfaced; the discipline was internalized from S5 MEMORY. MEMORY's description of prior-session discipline is a working mechanism for carrying guard-rails across sessions without re-docing them per-session.

**Methodology takeaway.** MEMORY-based guard-rail carry-over works when the rule is (a) simple (one line of check before an action), (b) associated with a specific action (gh pr create / gh pr merge), and (c) the prior session wrote the rule into MEMORY clearly. All three held for Check B.

**No proposal.** Positive confirmation that MEMORY-based discipline transfer works for this class of rule.
