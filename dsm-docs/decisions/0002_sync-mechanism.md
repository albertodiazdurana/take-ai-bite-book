# Decision 0002: Sync Mechanism — Scheduled Cron (pull-from-book-repo)

**Status:** Accepted (upstream reference corrected Session 2)
**Date:** 2026-04-17
**Session:** 1 (authored), Session 2 (upstream name corrected)
**Related:** BACKLOG-001 (R2), `dsm-docs/research/2026-04-17_cross-repo-sync_research.md`, Decision 0001

---

## Session 2 correction

This decision was originally written against "DSM Central" as the upstream.
The actual upstream the book renders is `take-ai-bite`
(`github.com/albertodiazdurana/take-ai-bite`), the public mirror of DSM
Central. The reasoning and mechanism of the decision are unchanged;
"Central" references throughout this file have been reworded to
"take-ai-bite" where they describe the upstream the book reads from. DSM
Central remains the methodology governance hub and is unaffected by this
correction.

---

## Context

The book must rebuild automatically when `take-ai-bite` (the public mirror
of DSM Central) publishes a new version, with zero manual intervention and
minimal maintenance overhead. Two strategy families were considered:
push-from-upstream (event-driven via `repository_dispatch`) and
pull-from-book-repo (scheduled cron polling the upstream's tags /
CHANGELOG).

## Decision

**Adopt scheduled cron in this repo (Family B). Daily run at 06:00 UTC,
with manual `workflow_dispatch` trigger also enabled.**

The workflow polls `take-ai-bite`'s latest release tag, compares against a
`.last-built-version` file committed in this repo, and rebuilds + redeploys
only if the version differs.

## Rationale (top 4 reasons)

1. **Zero cross-repo coupling.** No PAT, no GitHub App, no secret rotation.
   No PR required in DSM Central to wire this up. Family A required all
   three.

2. **Default `GITHUB_TOKEN` suffices.** `take-ai-bite` is a public repository,
   so read access (tags, CHANGELOG, raw file contents) needs no
   authentication beyond the token GitHub Actions issues automatically
   per workflow run. (DSM Central is private, which is exactly why
   take-ai-bite was introduced as the public mirror.)

3. **Hours-of-latency is invisible** for documentation reader experience.
   The push-trigger latency advantage (seconds vs hours) is decision-
   relevant only for live-coding or real-time content, not methodology
   docs.

4. **Failure mode is recoverable, not silent-stale.** Each cron run rebuilds
   from the latest Central tag, so a missed run is automatically caught up
   on the next run. No version is permanently skipped.

## Rejection of Family A (push-from-upstream)

- Requires a fine-grained PAT or GitHub App installation token stored as a
  secret in the upstream repo. PAT rotation (max 1-year expiry) is a
  recurring maintenance task that conflicts with the minimal-maintenance
  principle.
- Requires a new workflow file in the upstream repo + a new secret +
  cross-repo event-name coordination. Any change to the contract requires
  synchronized edits in two repos.
- The latency benefit (seconds vs hours) does not justify the coupling
  cost for documentation content.

## Consequences

- **Workflow file:** `.github/workflows/scheduled-build.yml` in this repo
  (to be created in implementation phase). Triggers: `schedule: cron`
  daily 06:00 UTC + `workflow_dispatch` for manual rebuild.
- **State file:** `.last-built-version` committed in this repo, holds the
  take-ai-bite version tag of the most recent successful build. Both the
  diff-detection and the 60-day inactivity workaround use it.
- **60-day inactivity gotcha mitigation:** Each successful build commits
  `.last-built-version` (even if unchanged, with a timestamp suffix on the
  commit message), keeping the schedule alive. Documented as a known
  GitHub Actions behavior, not a bug.
- **Upstream tagging dependency.** This decision assumes take-ai-bite carries
  git tags matching `^v\d+\.\d+\.\d+$`. Currently take-ai-bite has zero
  tags (verified Session 2, 2026-04-18). Tag propagation from DSM Central
  to take-ai-bite is the user's operational responsibility and must be
  resolved before Sprint 1 item G's first test fire. See BL-002 Open
  issues for context and fallbacks.
- **Build/deploy substrate:** `myst init --gh-pages` scaffold (per
  Decision 0001). The trigger (`on:`) is decoupled from the build job, so
  this decision is reversible without rewriting the build pipeline.
- **Failure visibility:** GitHub default workflow-failure email
  notifications to the repo owner. No additional alerting infrastructure.
- **Manual override:** `workflow_dispatch` allows a forced rebuild any time.

## Open follow-ups (deferred to implementation)

- Choose version-comparison source: `gh api repos/albertodiazdurana/
  take-ai-bite/releases/latest` (preferred, structured), raw
  `CHANGELOG.md` parse (fallback, viable since take-ai-bite mirrors
  Central's CHANGELOG), or both for redundancy. Session 2 note: with
  no tags yet on take-ai-bite, CHANGELOG parse is the immediate-viable
  fallback for the first test.
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
