# Decision 0001: Documentation Tool — Jupyter Book 2

**Status:** Accepted
**Date:** 2026-04-17
**Session:** 1
**Related:** BACKLOG-001 (R1), `dsm-docs/research/2026-04-17_tooling-comparison_research.md`

---

## Context

Six tools were evaluated against the BACKLOG-001 criteria: Markdown
compatibility with existing DSM_*.md files, navigation/search quality,
theming flexibility, maintenance overhead, future executable-code support,
and GitHub Pages compatibility.

Candidates: Jupyter Book 2, MkDocs + Material, Docusaurus, Sphinx + MyST,
mdBook, GitBook.

## Decision

**Adopt Jupyter Book 2 (MyST Document Engine stack).**

Project name and tool choice now align for the right reasons. Jupyter Book
was the working assumption from the project's inception, but version 2 is
a different product than version 1: rebuilt around the MyST Document Engine,
no Sphinx dependency, simpler authoring stack.

## Rationale (top 4 reasons)

1. **MyST Markdown is a CommonMark superset.** Existing DSM_*.md files
   render with minimal friction; admonitions, cross-references, and rich
   tables upgrade gradually rather than requiring a rewrite.

2. **Reader-friendly defaults out of the box.** Sidebar TOC, full-text
   search, citations, figures all work without theming effort. Matches
   the "minimal maintenance" and "reader-friendly" requirements
   simultaneously.

3. **Future executable code is a no-migration step.** Adding a notebook or
   executable cell to an existing book is config-only. No tool swap needed.

4. **Python toolchain matches the rest of the DSM ecosystem.** The `mystmd`
   CLI fits the existing development environment.

## Rejections (with reason)

- **MkDocs + Material:** Material for MkDocs entered maintenance mode in
  Nov 2025 (announced by maintainer Martin Donath). Strategic risk for a
  multi-year minimal-maintenance project. Future executable-code path is
  also second-class.
- **Docusaurus:** Node/React maintenance footprint too heavy for a
  single-author minimal-maintenance project. MDX adds preprocessing risk
  with existing GFM files.
- **Sphinx + MyST:** Reconstructs Jupyter Book 1's stack — exactly what
  Jupyter Book 2 was built to remove.
- **mdBook:** Reader-friendly but closes off future executable-code
  expansion; ecosystem is Rust-centric.
- **GitBook:** Vendor lock-in conflicts with the GitHub Pages requirement
  and DSM's open-methodology positioning.

## Consequences

- Toolchain: `mystmd` (Python CLI). Add to project dependencies.
- Build artifact target: GitHub Pages.
- R2 (cross-repo sync) inherits a follow-up: confirm Jupyter Book 2 has
  a GitHub Action for `repository_dispatch`-triggered builds, or that the
  CLI can run cleanly inside a scheduled GH Actions cron job.
- R3 (best practices) inherits a follow-up: verify MyST parsing
  performance on the largest DSM_*.md file (~7,800 lines).
- The `book/` directory referenced in CLAUDE.md will be the Jupyter Book
  source root (`mystmd init` output goes there).

## References

- `dsm-docs/research/2026-04-17_tooling-comparison_research.md` (full
  comparison and sources)
- `_reference/preliminary-plan.md` §4 (original research questions)
