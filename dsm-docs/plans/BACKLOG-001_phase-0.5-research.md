# BACKLOG-001: Phase 0.5 Research and Grounding

**Status:** Draft (pending approval)
**Priority:** High
**Date Created:** 2026-04-17
**Origin:** `_reference/preliminary-plan.md` Section 4 (Research Questions)
**Author:** Alberto Diaz Durana

---

## Goal

Complete Phase 0.5 (Research and Grounding) for the DSM Jupyter Book project so
that the implementation plan can be finalized with evidence-backed tool choices
and architecture decisions.

## Scope

Four research threads, each producing one file in `dsm-docs/research/`:

### R1. Documentation tool comparison
**File:** `2026-04-17_tooling-comparison_research.md`
**Question:** Is Jupyter Book the right tool, or does an alternative (MkDocs +
Material, Docusaurus, Sphinx, mdBook, GitBook) better fit the requirements?
**Comparison criteria:**
- Markdown compatibility with existing DSM_*.md files (Markdown variants supported)
- Navigation and search quality out of the box
- Theming flexibility and reader-friendly defaults
- Maintenance overhead (build time, deploy complexity, dependency stability)
- Future support for executable code/notebooks (DSM Future Consideration in
  preliminary plan §1)
- GitHub Pages compatibility
**Output:** Decision recommendation with explicit rationale and rejection reasons
for alternatives. Routed to `dsm-docs/decisions/` once approved.

### R2. Cross-repo sync mechanism (automatic, zero manual intervention)
**File:** `2026-04-17_cross-repo-sync_research.md`
**Top-level constraint:** "Minimal maintenance" requires the sync to run
*automatically* with no human in the loop. "Automatic" is not the same as
"trigger-on-tag" — scheduled polling is also automatic, on a different
timing model. R2 must compare both strategy families and recommend one.

**Question:** Which automation strategy best satisfies the
auto-sync + minimal-maintenance requirements simultaneously?

**Strategy family A — push-from-Central (event-driven):**
- GitHub Actions `repository_dispatch` (Central tag push → book repo workflow,
  via PAT or GitHub App)
- Webhook to a build service
- (Excluded: `workflow_dispatch` requires manual click, not automatic)

**Strategy family B — pull-from-book-repo (scheduled):**
- GH Actions cron job checks Central CHANGELOG / tags on a schedule
  (daily, hourly), rebuilds if the latest version differs from last build
- Scheduled job updates a Central submodule and rebuilds on diff

**Comparison axes:**
- Latency from Central tag to deployed update
- Cross-repo authentication footprint (PAT, GitHub App, none)
- Failure-mode visibility (silent miss vs. visible failure)
- Required changes to DSM Central (any change to Central is a coordination cost)
- Lock-in / vendor dependencies (GH Actions only vs. external webhook service)
- DSM Central release cadence reality check (looking at CHANGELOG, 1-2 bumps
  per week — does push-vs-pull latency matter at this cadence?)

**Output:** Decision with chosen strategy family, specific mechanism, secret/
permission requirements, failure modes, and the operational story for
"what happens when the sync silently breaks?". Routed to `dsm-docs/decisions/`.

### R3. Markdown documentation site best practices
**File:** `2026-04-17_doc-site-best-practices_research.md`
**Questions:**
- Multi-source content patterns (combining files from multiple repos)
- Version display (footer, header, version selector)
- Handling large markdown files (~7,800 lines like DSM_3) — pagination,
  anchor TOCs, performance
- Search index strategies for technical documentation
**Output:** List of patterns adopted/rejected for this project, with rationale.

### R4. Content scoping decisions
**File:** `2026-04-17_content-scope_research.md`
**Open questions from preliminary-plan.md §6 that need user input, not web research:**
- Should `case-studies/` be included in the book?
- Build on every tag, or only release tags matching `vX.Y.Z`?
- Copy content into book repo at build, or fetch from Central live?
- How to display DSM version in site title/footer?
**Output:** Documented decisions with rationale; this is more a structured
decision log than a research file. Could alternatively go directly to
`dsm-docs/decisions/`.

## Out of scope

- Implementation of the build pipeline (next sprint after research closes)
- Theme customization (post-build phase)
- Content authoring beyond what already exists in DSM Central

## Success criteria

- All four research files exist in `dsm-docs/research/`, each with a Status,
  Purpose, Target Outcome header per template
- Each research file ends with a clear recommendation
- R1 and R2 recommendations promoted to `dsm-docs/decisions/` and approved
- A revised plan replaces `_reference/preliminary-plan.md` (or `_reference/`
  contents are migrated to formal `dsm-docs/plans/` artifacts and the
  `_reference/` folder retired)

## Dependencies

- DSM_0.2 §17.1 alignment template (already applied in Session 1)
- Web search access for R1, R2, R3
- User input for R4

## Notes

- Research files are append-only during a session; mark `Status: Done` and move
  to `dsm-docs/research/done/` once findings are integrated
- Per `## Actionable Work Items` in CLAUDE.md, content in `_reference/` is
  INPUT to this BL, not a substitute for it. The preliminary plan informs R1-R4
  but does not decide them.

## Scope changelog

- **2026-04-17 (Session 1):** R2 reframed from a flat list of patterns into
  two strategy families (push-from-Central event-driven vs. pull-from-book-repo
  scheduled). "Automatic, zero manual intervention" elevated from implicit
  preliminary-plan requirement to explicit R2 top-level constraint. Triggered
  by user clarification mid-research after R1.
