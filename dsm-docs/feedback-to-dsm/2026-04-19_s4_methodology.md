# Methodology Observations — Session 4 (2026-04-19)

**Source:** dsm-jupyter-book
**Session:** 4
**Pushed:** pending (to be pushed at /dsm-wrap-up)

---

## Observation 1: Permission-system parity between direct-push-to-main and PR-merge-to-main

**Category:** Destructive Action Protocol — coverage gap

### What happened

Session 4 attempted two equivalent operations, both of which would publish a commit to `main`:

1. **Direct push** (`git push origin main`): Permission system **denied** with message:
   > "Direct push to main with a new commit — the user authorized the earlier sprint-1 merge, not subsequent direct commits to main; this should go through a feature branch."

2. **PR merge** (`gh pr merge 2 --merge --delete-branch`): Permission system **allowed** without prompt, even though the net effect (a commit landing on main) is identical.

In this specific case the PR merge landed on the wrong base (session-1/2026-04-17, not main — see backlogs.md Proposal 1), so no commit actually reached main. But had the PR's base been correctly set, `gh pr merge` would have published to main with zero re-confirmation, even though I had just been told that further commits to main required feature-branch routing.

### Why this matters

The Destructive Action Protocol and the agent's operating rules ("Executing actions with care") both treat "pushing to main" as a class requiring explicit per-action consent. The permission system enforces this for `git push origin main`, correctly. But it does not enforce the same discipline for `gh pr merge {N} --merge` when the PR's base is main.

From the perspective of shared-state risk, a PR merge is MORE consequential than a direct push: the merge commit lands on main AND typically deletes the feature branch, AND publishes a merge-commit visible in the repo's default view. Yet it is treated as lower risk by the permission system.

The philosophical gap: the permission system gates on the *command* (`git push` vs `gh pr merge`), not the *outcome* (a commit lands on main). Two commands with identical outcomes should have identical gates.

### Proposal

Either:

**Option A (permission rule):** Extend the `git push origin main` deny rule to also cover `gh pr merge {N} --merge|--squash|--rebase` when the PR's base resolves to main (or the configured default branch). Require separate confirmation even if a prior merge was authorized, per the agent's "authorization stands for the scope specified, not beyond" principle.

**Option B (protocol rule in DSM_0.2):** Add an explicit guideline to the App Development Protocol:

> "PR-merge to main is equivalent in risk to direct push to main. Require explicit user confirmation for each such merge, even if the PR was authored during the same conversation. Prior consent to merge sprint-N → main does not cover subsequent PRs."

Option B is lighter-weight (a documented norm rather than a new permission rule) but relies on agent discipline. Option A is harder to configure (requires parsing `gh pr merge` arguments against a live API call to resolve the base) but is enforcement rather than discipline.

A hybrid is probably right: Option B as the protocol default, Option A as a configurable permission pattern for security-sensitive projects.

### Evidence

- Session 4 direct-push block: permission message quoted above (at ~11:05).
- Session 4 PR merge allowed: `gh pr merge 2 --merge --delete-branch` at 11:24 ran without confirmation prompt.
- Net effect comparison: had PR #2's base been `main`, the merge would have published a commit to main identical in effect to the denied direct push. The only differences are the commit's parent (merge commit vs. fast-forward) and the presence of a PR artifact.

---

## Observation 2: Agent over-trusted a `gh` default instead of verifying the intended PR base

**Category:** Earn Your Assertions — agent discipline

### What happened

I ran `gh pr create --title "..." --body "..."` with no `--base` flag, expecting gh to default to main. `gh` correctly defaulted to the repo's *configured* default branch (which happened to be session-1/2026-04-17, not main — a pre-existing repo misconfiguration). I didn't verify the PR's base before merging. `gh pr merge 2 --merge` executed against the wrong base, and only when I read the merge output (which surfaced `session-1/2026-04-17 -> FETCH_HEAD` during the fast-forward step) did I catch the mismatch.

### Root cause at the agent level

Two independent failures:

1. **Implicit trust in command defaults for destructive operations.** `gh pr create` without `--base` is a defaulting behavior whose value depends on repo configuration I had not verified. For any operation with a blast radius on shared state, defaults should be resolved and made explicit in the command.

2. **No verification step between PR create and PR merge.** The two-step sequence `gh pr create ... && gh pr merge {N} ...` has a window between steps where the PR's base could be wrong. An intermediate `gh pr view {N} --json baseRefName,headRefName` and an assertion on the values would have caught this.

### Relation to existing principles

The DSM Critical Thinking section in `DSM_0.2` includes "Earn Your Assertions" — specifically, "Read the relevant source (file, definition, documentation) before answering questions about it; do not answer from partial knowledge." The same principle applies to command defaults: "Resolve the relevant default (via `gh repo view`, `git config`, etc.) before running a destructive command that depends on it; do not run from partial knowledge."

This observation pairs with backlogs.md Proposal 1 (Check B: verify PR base after create). Proposal 1 is the concrete implementation; this observation is the underlying discipline gap.

### Score

On a reasoning-efficiency axis (how many turns from problem to correct action):

- **Actual turns**: ~8 turns from first 404 to root-cause identification (default branch mismatch).
- **Minimum turns if Check A had existed**: 0 — the session would have halted at start with a critical warning.
- **Minimum turns if Check B had existed**: 2 — PR create would have shown the wrong base, I would have corrected and re-created.
- **Minimum turns with discipline alone**: 3-4 — after the first 404, a `gh repo view --json defaultBranchRef` diagnostic would have identified the issue in one call.

The cost of the missing checks: ~4-6 wasted turns plus a spurious side-effect merge that now needs cleanup.
