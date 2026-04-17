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

### R2. Cross-repo sync mechanism
**File:** `2026-04-17_cross-repo-sync_research.md`
**Question:** What is the most reliable, low-maintenance pattern to trigger a
build of this book when DSM Central pushes a release tag?
**Patterns to evaluate:**
- GitHub Actions `repository_dispatch` (Central -> book repo via PAT)
- GitHub Actions `workflow_dispatch` with scheduled poll
- Git submodules (Central as submodule of book repo)
- Direct fetch at build time (book repo clones Central in workflow)
- Webhook to GitHub Pages deploy
**Output:** Decision with chosen mechanism, secret/permission requirements,
and failure modes. Routed to `dsm-docs/decisions/`.

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
