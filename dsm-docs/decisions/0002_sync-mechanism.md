# Decision 0002: Sync Mechanism — Scheduled Cron (pull-from-book-repo)

**Status:** Accepted
**Date:** 2026-04-17
**Session:** 1
**Related:** BACKLOG-001 (R2), `dsm-docs/research/2026-04-17_cross-repo-sync_research.md`, Decision 0001

---

## Context

The book must rebuild automatically when DSM Central publishes a new version,
with zero manual intervention and minimal maintenance overhead. Two strategy
families were considered: push-from-Central (event-driven via
`repository_dispatch`) and pull-from-book-repo (scheduled cron polling
Central's tags / CHANGELOG).

## Decision

**Adopt scheduled cron in this repo (Family B). Daily run at 06:00 UTC,
with manual `workflow_dispatch` trigger also enabled.**

The workflow polls DSM Central's latest release tag, compares against a
`.last-built-version` file committed in this repo, and rebuilds + redeploys
only if the version differs.

## Rationale (top 4 reasons)

1. **Zero cross-repo coupling.** No PAT, no GitHub App, no secret rotation.
   No PR required in DSM Central to wire this up. Family A required all
   three.

2. **Default `GITHUB_TOKEN` suffices.** DSM Central is a public repository,
   so read access (tags, CHANGELOG, raw file contents) needs no
   authentication beyond the token GitHub Actions issues automatically
   per workflow run.

3. **Hours-of-latency is invisible** for documentation reader experience.
   The push-trigger latency advantage (seconds vs hours) is decision-
   relevant only for live-coding or real-time content, not methodology
   docs.

4. **Failure mode is recoverable, not silent-stale.** Each cron run rebuilds
   from the latest Central tag, so a missed run is automatically caught up
   on the next run. No version is permanently skipped.

## Rejection of Family A (push-from-Central)

- Requires a fine-grained PAT or GitHub App installation token stored as a
  secret in DSM Central. PAT rotation (max 1-year expiry) is a recurring
  maintenance task that conflicts with the minimal-maintenance principle.
- Requires a new workflow file in DSM Central + a new secret + cross-repo
  event-name coordination. Any change to the contract requires synchronized
  edits in two repos.
- The latency benefit (seconds vs hours) does not justify the coupling
  cost for documentation content.

## Consequences

- **Workflow file:** `.github/workflows/scheduled-build.yml` in this repo
  (to be created in implementation phase). Triggers: `schedule: cron`
  daily 06:00 UTC + `workflow_dispatch` for manual rebuild.
- **State file:** `.last-built-version` committed in this repo, holds the
  Central version tag of the most recent successful build. Both the
  diff-detection and the 60-day inactivity workaround use it.
- **60-day inactivity gotcha mitigation:** Each successful build commits
  `.last-built-version` (even if unchanged, with a timestamp suffix on the
  commit message), keeping the schedule alive. Documented as a known
  GitHub Actions behavior, not a bug.
- **Build/deploy substrate:** `myst init --gh-pages` scaffold (per
  Decision 0001). The trigger (`on:`) is decoupled from the build job, so
  this decision is reversible without rewriting the build pipeline.
- **Failure visibility:** GitHub default workflow-failure email
  notifications to the repo owner. No additional alerting infrastructure.
- **Manual override:** `workflow_dispatch` allows a forced rebuild any time.

## Open follow-ups (deferred to implementation)

- Choose version-comparison source: `gh api repos/.../releases/latest`
  (preferred, structured), raw `CHANGELOG.md` parse (fallback), or both
  for redundancy.
- Decide whether to filter on release tags (`vX.Y.Z`) only, vs all tags
  (R4 covers this).
- Choose the diff strategy when CHANGELOG version differs: full re-clone
  + rebuild, or incremental fetch + partial rebuild. Default to full
  rebuild for simplicity.

## References

- `dsm-docs/research/2026-04-17_cross-repo-sync_research.md` (full
  comparison and sources)
- Decision 0001 (Jupyter Book 2 / `myst init --gh-pages`)
- `_reference/preliminary-plan.md` §3 (Auto-sync, Minimal maintenance
  requirements)
