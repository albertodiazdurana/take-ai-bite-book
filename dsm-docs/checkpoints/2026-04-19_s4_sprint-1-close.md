# Sprint 1 closure checkpoint

**Sprint:** 1 (BACKLOG-002)
**Sessions:** 2, 3, 4
**Closed:** 2026-04-19 (Session 4)
**Branch at close:** `sprint-1/2026-04-17` (already merged to main via PR-less direct merge at 11:00; kept alive through Session 4 for closure work)

---

## Outcome summary

Sprint 1 delivered a **Minimum Viable Sync Pipeline** that:

1. Detects new tags on take-ai-bite via `gh api` + strict semver filter (`scripts/check-upstream-version.sh`, exit-code contract 0/10/1)
2. Shallow-clones take-ai-bite at the latest tag, copies 43 markdown files into `book/content/` (`scripts/copy-upstream-content.sh`)
3. Rewrites `book/myst.yml` `site.options.logo_text` + `site.parts.footer` with the tag + build date (`scripts/inject-version.sh`)
4. Builds the MyST site (`myst build --html`, 14 s on ubuntu-latest)
5. Uploads + deploys to GitHub Pages (3 s upload + 6 s deploy)
6. Commits `.last-built-version` back to the repo to keep the schedule alive past GH-Actions' 60-day-inactivity gotcha

**First green build:** run [24626613594 (fail)](https://github.com/albertodiazdurana/take-ai-bite-book/actions/runs/24626613594) then run [24626654340 (success)](https://github.com/albertodiazdurana/take-ai-bite-book/actions/runs/24626654340) on 2026-04-19 at 10:11:30 UTC. Total job wall time: 33 seconds.

**Live site:** https://albertodiazdurana.github.io/take-ai-bite-book/
**Built version at close:** v1.5.4 (drifted up from the v1.5.3 Sprint 1 target during the session — DSM Central released v1.5.4 today, and BL-376's tag mirror propagated it to take-ai-bite before the first green build; the `force=true` path correctly grabbed the latest available tag, which is the intended steady-state behavior)

## Exit criteria

| # | Criterion | Status | Evidence |
|---|-----------|--------|----------|
| 1 | Site deploys via manual `workflow_dispatch` | **Met** | Run 24626654340, conclusion=success, 33s wall time |
| 2 | Title shows `DSM Methodology — v<tag>` | **Met (with version drift)** | Deployed title: `DSM Methodology, v1.5.4` (target was v1.5.3; see drift note above) |
| 3 | Footer shows `Built from DSM v<tag> (<date>)` + LICENSE link | **Met** | `Built from DSM v1.5.4 (2026-04-19)` · License → `github.com/albertodiazdurana/take-ai-bite/blob/main/LICENSE` |
| 4 | `.last-built-version` contains built tag | **Met** | `v1.5.4` committed by workflow (commit 04bc223) |
| 5 | R3 measurement items recorded | **Met** | `dsm-docs/research/2026-04-17_doc-site-best-practices_research.md` §Sprint 1 item H section appended this session |
| 6 | No scheduled cron active | **Met** | Schedule stanza commented in `scheduled-build.yml` with Sprint 2 note |

All 6 exit criteria met. Version drift on #2 is a feature, not a bug: the plan's v1.5.3 target was written when v1.5.3 was the newest; the pipeline correctly tracks "latest".

## Measurements (item H)

| Metric | Value |
|---|---|
| mystmd build wall time | 14 s (step 10 of 13) |
| Job wall time (whole pipeline) | 33 s |
| Largest page load | 83 KB (`index.html`, single-page SPA) |
| Search index size | 10 KB (`myst.search.json`) |
| Pages artifact (zipped) | 15.4 MB |
| Pages artifact (uncompressed) | 68 MB |

## Surprises surfaced during sprint execution

Three setup-level GitHub misconfigurations blocked Item G on the first three attempts. None were in the workflow code; all were in repo configuration. Documented in `dsm-docs/research/...` and routed to DSM Central as feedback (`dsm-docs/feedback-to-dsm/2026-04-19_s4_*.md`):

1. **GitHub-side default branch was `session-1/2026-04-17`, not `main`.** Set at repo creation, never flipped. `workflow_dispatch` 404'd because GitHub's workflow-indexer only tracks the configured default branch.
2. **Sprint-branch-to-main merge did not trigger first-workflow registration.** GitHub's indexer needs a push that directly modifies a workflow file on the default branch. Required a PR (ops branch) to touch `scheduled-build.yml` on main.
3. **`github-pages` environment had a branch-policy pinning `session-1/2026-04-17`.** Auto-created during Pages-source configuration, captured the then-default-branch. After flipping default to main, the policy didn't auto-update; the first post-flip dispatch failed in 4 s at the environment gate before any step ran.

**Side-effect debris left by the diagnosis loop:** one PR #2 merged into a stale session branch (session-1/2026-04-17) due to `gh pr create` defaulting to the misconfigured default branch; no functional impact but session-1 now has spurious fast-forwarded Sprint 1 content. Documented in methodology feedback as a Check-B guardrail proposal (verify PR base before merge).

## Follow-up BLs spawned

- **BL proposal (feedback-to-dsm):** `/dsm-go` default-branch verification + explicit `--base` passing in agent-invoked `gh pr create`. Priority: **High**. File: `dsm-docs/feedback-to-dsm/2026-04-19_s4_backlogs.md`.
- **Methodology observation (feedback-to-dsm):** Permission-system parity gap between `git push origin main` (denied) and `gh pr merge N --merge` to main (allowed). File: `dsm-docs/feedback-to-dsm/2026-04-19_s4_methodology.md`.
- **Sprint 2 optimization candidate (project-local):** Artifact is 68 MB uncompressed / 15 MB zipped, dominated by plotly (~19 MB) + thebe (~1.3 MB + chunks) runtimes that the prose-only DSM corpus does not use. Stripping would reduce deploy size ~90 %. To be formalized as a Sprint 2 BL during Sprint 2 planning.

## Branch state at close

- `main` at `04bc223` (workflow's automatic commit-back of `.last-built-version`)
- `origin/main` synced
- `sprint-1/2026-04-17` local + remote at `13caafa` (lagging main by the touch-registration PR + the automatic commit-back, since sprint-1 hasn't pulled those back; no need, sprint-1 is being closed)
- `session-1/2026-04-17` local + remote: dirty with spurious Sprint 1 content from PR #2's misdirected merge; dead branch, cleanup deferred (low-priority tidy-up)
- `ops/trigger-workflow-registration-v2` deleted (local + remote) after PR #3 merge

**Recommended post-session cleanup (not blocking):**
- Delete `session-1/2026-04-17` (both local and remote) — it's fully merged to main and the accidental Sprint 1 fast-forward makes it cosmetically noisy
- Delete `session-2/2026-04-17` local-only branch (no remote counterpart)
- Delete `sprint-1/2026-04-17` both local and remote once this session wraps

## Next steps (Sprint 2)

**Goal:** move from "first green build, manual trigger" to "scheduled daily build, quiet steady-state".

**Key deliverables:**
1. Uncomment the schedule stanza in `scheduled-build.yml` (`cron: '0 6 * * *'`) and verify at least one auto-triggered build completes green overnight.
2. Address the artifact-bloat finding: strip unused executable-content runtime (plotly/thebe) from the theme build. Target ~90 % artifact-size reduction. Formalize as a BL after Sprint 2 research phase.
3. Move the H research file (`dsm-docs/research/2026-04-17_doc-site-best-practices_research.md`) to `done/` now that Sprint 1 consumed its measurement items.
4. Address project-local version-drift reporting: when `force=true` rebuilds to a newer tag than the plan's target, surface the drift in the wrap-up report so it's not silent.

**Sprint 2 plan:** to be formalized as BACKLOG-003 once Sprint 2 research (if any) closes.

## Artifacts produced this sprint

- `scripts/check-upstream-version.sh`, `copy-upstream-content.sh`, `inject-version.sh` — three production bash scripts, total ~200 lines
- `.github/workflows/scheduled-build.yml` — 139 lines of orchestrator
- `.github/workflows/deploy.yml` — 62 lines of deploy-only utility workflow
- `book/myst.yml` — MyST configuration with version-injection anchors
- `package.json` + `package-lock.json` — Node env pin
- Decisions 0002, 0003 updated during Session 2
- Research file H section (95 lines) added this session
- README.md created this session (Sprint 1 exit criterion #7)
- One live deployed Pages site

## Session 4's contribution to closure

- Pending-commit cleanup from Session 3's late `/dsm-align` run (CLAUDE.md regen + inbox notification → commit 13caafa, then archived to inbox/done)
- Merged sprint-1 → main (commit 9c505d9, 11 commits + merge commit)
- PR #3 (touch-workflow-registration) to unblock GitHub's workflow indexer
- Env policy swap: session-1 → main on github-pages environment
- First green build: run 24626654340
- H measurements extracted from run artifact and written to research file
- Three feedback files to DSM Central (backlogs + methodology)
- This checkpoint
- Blog journal entry
- README.md creation
