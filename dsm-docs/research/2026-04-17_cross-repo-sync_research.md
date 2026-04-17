# R2: Cross-repo sync mechanism (automatic, zero manual intervention)

**Date:** 2026-04-17
**BL:** BACKLOG-001
**Status:** In progress (recommendation drafted, pending decision promotion)
**Author:** Alberto Diaz Durana

---

## Purpose

Choose the automation strategy that best satisfies "auto-sync from DSM Central
on version bump" + "minimal maintenance" simultaneously.

## Target Outcome

A decision recommendation with chosen strategy family, specific mechanism,
secret/permission requirements, failure modes, and the operational story for
silent breakage. Promotable to `dsm-docs/decisions/`.

## Constraint reframing (from BL-001 scope edit)

"Automatic" is not the same as "trigger-on-tag". Two strategy families are
genuinely automatic:

- **Family A — push-from-Central (event-driven):** Central tag-push fires
  a `repository_dispatch` event into this repo, triggering a build.
- **Family B — pull-from-book-repo (scheduled):** This repo's GH Actions
  cron polls Central's tags / CHANGELOG on a schedule, builds if version
  changed.

Both are automatic. The trade-off is who owns the trigger.

---

## Findings

### Family A: push-from-Central (`repository_dispatch`)

**Mechanism:**
1. DSM Central adds a workflow that fires on tag push: `on: push: tags:
   ['v*']`.
2. Workflow calls the GitHub REST API (`POST /repos/{owner}/{repo}/dispatches`)
   against this repo with an `event_type` and optional `client_payload`
   (e.g., the new version).
3. This repo has a workflow with `on: repository_dispatch: types:
   [dsm-version-bumped]` that runs the build + deploy.

**Authentication (the load-bearing detail):**
- The default `GITHUB_TOKEN` **cannot** cross repository boundaries; this
  is documented and intentional. So Central's workflow needs either:
  - A **fine-grained PAT** stored as a secret in Central (`Contents:
    Read and write` or `Actions: Write` scoped only to this repo), OR
  - A **GitHub App installation token** with the same minimal scope.
- Best-practice signal: fine-grained PAT, scoped to a single repository,
  with the smallest permission set that works (`Contents: Read and write`
  is the common pattern for triggering dispatch).
- GitHub App is more "correct" (no human-tied token) but adds the
  overhead of creating, installing, and maintaining the app. For a
  single-author project, that overhead exceeds the benefit.

**Latency:** Seconds from tag push to build start.

**Failure modes:**
- PAT expires (fine-grained PATs can be set to up-to-1-year expiry, after
  which the workflow silently 401s). PAT rotation is the main maintenance
  burden.
- Central workflow file drifts (e.g., wrong `event_type`); silent miss.
- Cross-repo coupling: changing the `event_type` requires synchronized
  edits in two repos.

**Required Central-side changes:**
- New workflow file in DSM Central (`.github/workflows/dispatch-jupyter-
  book.yml`).
- New secret in Central holding the PAT.
- Coordination: any change to event name / payload schema requires a
  PR in Central.

### Family B: pull-from-book-repo (scheduled cron)

**Mechanism:**
1. This repo has a workflow with `on: schedule: - cron: '0 6 * * *'`
   (e.g., daily at 06:00 UTC).
2. Workflow checks Central's latest release/tag via GitHub API or
   reads CHANGELOG.md from the raw URL.
3. Compares against the last-built version stored in this repo (could
   be a `.last-built-version` file committed back, or a workflow output
   stored in cache, or just compare against the deployed site's version
   marker).
4. If version differs: clone Central, build with `mystmd build`, deploy
   to GH Pages.
5. If version matches: exit 0, no-op.

**Authentication:**
- No PAT required for read access to a public repository (DSM Central
  is public per the GitHub URL pattern).
- The default `GITHUB_TOKEN` is sufficient for everything inside this
  repo (commit `.last-built-version`, deploy to GH Pages).
- Zero cross-repo secrets.

**Latency:** Up to the cron interval. At daily cadence: up to 24h.
At hourly: up to 1h. (GitHub Actions schedule events can be queued and
delayed by GitHub itself, so "exactly on the hour" is not guaranteed.)

**Failure modes:**
- **GitHub disables scheduled workflows on inactive repos** (no commits
  for 60 days). Workaround: a small monthly commit (e.g., updating a
  timestamp file) keeps the schedule alive. This is a documented gotcha
  for "minimal maintenance" projects, ironic but real.
- Cron drift: GitHub's note that "the action may not run at that exact
  time" — at daily cadence this is irrelevant; at sub-hour cadences it
  matters.
- Silent miss: if Central tags v1.6.0 at 09:00 and the cron runs at 06:00
  UTC daily, the next build is ~21h later. Acceptable for documentation
  sync.

**Required Central-side changes:** None.

### Reality check: DSM Central release cadence

Central CHANGELOG (read at session start) shows v1.5.0, v1.5.1, v1.5.2 all
on 2026-04-16. Recent history shows ~1-3 version bumps per week, occasionally
multiple per day during active sprints.

Implications:
- Push-latency advantage (Family A) is meaningful only when readers expect
  real-time updates. For DSM methodology docs, hours-of-latency is
  acceptable. The reader experience between "deployed within 60 seconds"
  and "deployed within 6 hours" is functionally identical.
- However, multiple bumps per day means an hourly cron on Family B would
  rebuild ~1-3 times per active day, which is fine; a daily cron might
  miss intermediate versions but each rebuild always pulls the latest
  Central state, so no version is permanently skipped.

### Jupyter Book 2 deploy story (relevant to both families)

`myst init --gh-pages` scaffolds a complete deploy workflow targeting
GitHub Pages. The workflow uses GitHub Pages "GitHub Actions" source mode
(not the legacy `gh-pages` branch). Either family can call this generated
workflow; the trigger is decoupled from the build.

This means: **the build/deploy job is the same in both families**; only
the `on:` trigger differs. Decision can be revisited later (switch from
cron to dispatch or vice versa) by changing one workflow file.

---

## Recommendation

**Adopt Family B (pull-from-book-repo, scheduled cron) — daily UTC.**

### Why it wins

1. **Zero cross-repo coupling.** No PAT, no secret, no Central-side
   workflow, no PR required in Central to wire it up. This matches
   "minimal maintenance" more strongly than Family A does.

2. **DSM Central remains untouched.** Single-author project, single
   maintainer, single repo to think about for this concern.

3. **The latency penalty is a non-issue at this content type.** Hours
   of latency on documentation sync is invisible to readers.

4. **Failure mode is recoverable.** If a daily build is missed, the
   next day's cron pulls the latest state. No version is permanently
   skipped (state is "rebuild from latest Central tag" every run).

5. **The 60-day inactivity gotcha has a known cheap fix:** the workflow
   can touch a `.last-build-timestamp` file each successful run and commit
   it back, which counts as activity and keeps the schedule alive
   indefinitely.

### Why Family A was rejected

- PAT/GitHub App overhead exceeds latency benefit.
- PAT rotation is a recurring maintenance task that conflicts with the
  "minimal maintenance" principle.
- Cross-repo coupling means any future change to the trigger contract
  requires synchronized edits in two repos — unnecessary friction for
  a single-author setup.

### Specific mechanism

```yaml
# .github/workflows/scheduled-build.yml
on:
  schedule:
    - cron: '0 6 * * *'    # 06:00 UTC daily
  workflow_dispatch:        # also allow manual rebuild
```

Build steps:
1. Check Central's latest release tag via `gh api repos/...` (uses
   default `GITHUB_TOKEN`, public repo, no PAT).
2. Compare against `.last-built-version` in this repo.
3. If equal → exit 0 (no-op).
4. If different →
   - clone DSM Central at the new tag,
   - copy `DSM_*.md` and community files into `book/`,
   - run `mystmd build`,
   - deploy via the generated `myst init --gh-pages` action,
   - update `.last-built-version`, commit, push.

### Operational story for silent breakage

- Workflow failures email the repo owner via GitHub's default
  notifications (active by default for the owner).
- A monthly self-touch commit (or just the daily commit of
  `.last-built-version` after a successful build) keeps the schedule
  active even with no manual commits.
- Manual `workflow_dispatch` trigger lets the owner force a rebuild
  any time.
- If Central CHANGELOG format changes, the version-detection step fails
  visibly (workflow fails, email fires). No silent stale state.

### Open follow-ups (for R3 and beyond)

- R3: Verify MyST build performance on the largest DSM_*.md file
  (~7,800 lines) — drives the choice between daily and hourly cadence.
- Implementation: choose the version-comparison source (Git tag via
  `gh api`, raw CHANGELOG.md, or both for redundancy).
- R4: Decide whether to build on every tag or only release tags
  matching `vX.Y.Z` (CHANGELOG currently uses `vX.Y.Z`-only, so a
  simple tag filter works).

---

## Sources

- [GitHub Pages and Actions — Jupyter Book User Guide](https://jupyterbook.org/en/stable/publish/gh-pages.html)
- [Deploy to GitHub Pages — MyST Markdown](https://mystmd.org/guide/deployment-github-pages)
- [Deploy Pages directly from GitHub action — issue #404, jupyter-book/mystmd](https://github.com/jupyter-book/mystmd/issues/404)
- [Cross-Repository Workflows in GitHub Actions — OneUptime](https://oneuptime.com/blog/post/2025-12-20-cross-repository-workflows-github-actions/view)
- [Triggering by other repository — GitHub Community Discussion #26323](https://github.com/orgs/community/discussions/26323)
- [Triggering Workflows in Another Repository with GitHub Actions — Medium](https://medium.com/hostspaceng/triggering-workflows-in-another-repository-with-github-actions-4f581f8e0ceb)
- [Scheduled Workflows (Cron) in GitHub Actions — OneUptime](https://oneuptime.com/blog/post/2025-12-20-scheduled-workflows-cron-github-actions/view)
- [Run your GitHub Actions workflow on a schedule — Jason Etcovitch](https://jasonet.co/posts/scheduled-actions/)
- [Scheduled action in fork keeps getting disabled — GitHub Community Discussion #181236](https://github.com/orgs/community/discussions/181236) (60-day inactivity gotcha)
