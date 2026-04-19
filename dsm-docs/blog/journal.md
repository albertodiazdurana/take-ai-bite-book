# Blog Journal

Append-only capture file for blog-worthy observations. Entries accumulate
across sessions and are extracted into materials files at project/epoch end.
Reference: DSM_0.1 Blog Artifacts (three-document pipeline).

## Entry Template

### [YYYY-MM-DD] {Title}
{Observation, story, pattern, or insight}

---

### [2026-04-19] First green build, and the three configs that looked like infrastructure bugs

Sprint 1 closed today with a 33-second end-to-end build: pull the latest tag from take-ai-bite, copy 43 markdown files into `book/content/`, rewrite `myst.yml` with the version string, build with mystmd (14 s of that total), upload, deploy. Site's live at https://albertodiazdurana.github.io/take-ai-bite-book/.

But the interesting part wasn't the 33-second build. It was the hour before it.

After merging sprint-1 → main, I fired `gh workflow run scheduled-build.yml` and got HTTP 404. "Workflow not found on the default branch." But the file *was* on main — verified via `gh api .../contents/`. Tried again. Still 404. Queried `gh api .../actions/workflows` and got `total_count: 0` — GitHub had not indexed any workflow, even though two YAML files were sitting right there in `.github/workflows/`.

The rabbit hole began. First theory: registration lag, just wait. Armed a 3-min monitor. Timed out. Armed a 10-min monitor. Timed out. Tried a direct touch-push to main to force indexing; permission system denied with the (correct) reminder that I only had consent for the sprint-1 merge, not arbitrary subsequent commits to main. Created an `ops/trigger-workflow-registration` branch, opened a PR , and it merged into `session-1/2026-04-17`, not main.

That was the clue. Why did `gh pr create` default to session-1 as base? Because `gh repo view --json defaultBranchRef` showed `session-1/2026-04-17`. The repo's default branch on GitHub was never main. It had been set to whatever branch existed at repo creation, and the merge-to-main just made commits land on a non-default branch that GitHub's indexer didn't care about.

User flipped the default branch to main via Settings. New workflow run: failed in 4 seconds, zero steps executed. Third config: the `github-pages` environment, auto-created when Pages source was set to Actions, had pinned a deployment-branch-policy to session-1. Swapped the policy via API. Fired again. Green.

Three configs, each benign on its own, each explicable by some default GitHub made when the repo was young. Together they produced a failure mode whose symptom (HTTP 404) pointed at nothing like the actual cause.

The methodology observation for DSM: every one of these could have been caught earlier by a `/dsm-go` Step 2a that diffs local main against the remote's configured default branch. Added to feedback-to-dsm as a High-priority BL. The pattern is: when an agent's mental model of the remote diverges from the remote's actual config, the failure symptoms masquerade as bugs in the code. A single `gh repo view` call at session start turns this class of bug into a halting error instead of a 45-minute detour.

Side observation on the build output: the 15-MB zipped Pages artifact is 90 % plotly + thebe JS runtime that this prose-only corpus never invokes. The book-theme ships interactive-content infrastructure unconditionally. A Sprint 2 BL candidate: trim to prose-only and see how small the deploy gets.

Sprint 1 is closed. Sprint 2 starts with: activate the schedule, trim the bundle, formalize BL-003.
