# R1: Documentation Tool Comparison

**Date:** 2026-04-17
**BL:** BACKLOG-001
**Status:** In progress (recommendation drafted, pending decision promotion)
**Author:** Alberto Diaz Durana

---

## Purpose

Choose the documentation tool that best fits the DSM Jupyter Book project,
or document why Jupyter Book (the project's namesake working assumption)
should be replaced.

## Target Outcome

A decision recommendation with explicit rationale and rejection reasons for
the alternatives, ready to promote to `dsm-docs/decisions/`.

## Comparison Criteria (from BACKLOG-001)

| Criterion | Why it matters here |
|-----------|---------------------|
| Markdown compatibility | Existing DSM_*.md files use GitHub-flavored Markdown with tables, fenced code, headings; tool must render without conversion |
| Navigation & search | Reader-friendly is an explicit project requirement; out-of-the-box quality matters more than custom-built |
| Theming flexibility | Reader-friendly defaults preferred over heavy customization; project is single-author, no design budget |
| Maintenance overhead | "Minimal maintenance" is an explicit project requirement |
| Future executable code | Preliminary plan §1 calls out interactive/executable docs as a future consideration |
| GitHub Pages | Required (free, integrated with GitHub; only deploy target in plan) |

---

## Candidates evaluated

1. **Jupyter Book 2** (working assumption)
2. **MkDocs + Material theme**
3. **Docusaurus** (Meta)
4. **Sphinx** (with MyST extension)
5. **mdBook** (Rust)
6. **GitBook** (proprietary SaaS)

## Findings

### Jupyter Book 2

- **Status:** Active development. Rebuilt around the **MyST Document Engine**,
  removing the previous Sphinx dependency. Authored by the Executable Books
  Project / `jupyter-book` GitHub org.
- **Markdown:** MyST Markdown (superset of CommonMark + directives). Existing
  GFM files render with minimal friction; admonitions, cross-refs, and rich
  tables are first-class via MyST roles.
- **Navigation/search:** Built-in book-style sidebar TOC, full-text search,
  cross-document references. Defaults are reader-friendly without theming work.
- **Theming:** Theme system inherited from MyST; custom CSS supported.
  Defaults are publication-grade.
- **Maintenance:** Python toolchain (`mystmd` CLI). MyST is a structured
  document model, so format stability is part of the product (driven by
  scientific publishing requirements). Active 2025-2026 release cadence.
- **Executable code:** Native. Notebooks render with executable output;
  Markdown-only books can stay Markdown-only with no notebook overhead.
  Future "add code examples" is a no-migration step.
- **GitHub Pages:** Standard target; deploy via `gh-pages` branch or
  GitHub Action.
- **Risk:** Jupyter Book 2 / MyST stack is younger than v1 (Sphinx-based);
  some v1 plugin ecosystem doesn't carry over. Acceptable since DSM book
  has no plugin requirements yet.

### MkDocs + Material

- **Status:** **Material for MkDocs entered maintenance mode in November
  2025** (announced by maintainer Martin Donath). Bug fixes and security
  patches continue; no new features. MkDocs core remains active.
- **Markdown:** CommonMark + extensive plugin extensions. Excellent GFM
  fidelity; very wide plugin ecosystem.
- **Navigation/search:** Material's defaults are excellent: instant search,
  responsive sidebar, admonitions, content tabs.
- **Theming:** Material is the de-facto default; non-Material themes exist
  but Material is what makes MkDocs reader-friendly out of the box.
- **Maintenance:** Python-only, simple `mkdocs.yml`. Build is fast.
  However, the Material maintenance freeze is a strategic risk for a
  "minimal maintenance" project on a multi-year horizon: any new
  requirement (Material plugin, theme feature) is now a fork-or-rewrite
  decision.
- **Executable code:** No native executable code. Plugins exist
  (`mkdocs-jupyter`) but executable docs are second-class.
- **GitHub Pages:** First-class (`mkdocs gh-deploy`).
- **Risk:** Material maintenance freeze. The "future executable code"
  requirement requires plugin scaffolding that Jupyter Book provides
  natively.

### Docusaurus

- **Status:** Actively maintained by Meta.
- **Markdown:** MDX (Markdown + JSX). GFM fidelity is good but DSM_*.md
  files using JSX-incompatible syntax (e.g., bare `<word>` patterns) would
  need preprocessing. MyST-style rich directives are not native; admonitions
  exist but feel JSX-flavored.
- **Navigation/search:** Excellent. Multi-version docs, sidebar groups,
  Algolia DocSearch integration out of the box.
- **Theming:** React-based, very flexible, also higher floor of effort.
- **Maintenance:** Node/npm/React stack. Build performance has improved but
  is heavier than Python static generators. Dependency update churn is
  larger (React major versions, Node LTS).
- **Executable code:** Not native. Possible via embedded iframes or
  custom React components; scientific notebooks are not first-class.
- **GitHub Pages:** Supported via deploy script; standard pattern.
- **Risk:** Heaviest maintenance footprint of the candidates. Mismatch
  with single-author / minimal-maintenance constraints.

### Sphinx (with MyST extension)

- **Status:** Active. MyST extension (`myst-parser`) lets Sphinx ingest
  Markdown.
- **Markdown:** Via MyST extension; same superset Jupyter Book 2 uses.
- **Navigation/search:** Built-in. Themes (Furo, sphinx-book-theme) are
  reader-friendly.
- **Theming:** Mature ecosystem; many production-grade themes.
- **Maintenance:** Python toolchain. Sphinx is the most mature in this list
  but configuration (conf.py, RST legacy, build pipeline) carries decades
  of complexity. Pure-Markdown projects often prefer MkDocs or Jupyter
  Book to avoid the Sphinx config surface.
- **Executable code:** Via `myst-nb` / `jupyter-sphinx`. Possible but layered.
- **GitHub Pages:** Standard pattern.
- **Risk:** Higher complexity than Jupyter Book 2 for the same MyST
  experience. Choosing Sphinx + MyST + book theme largely reconstructs
  what Jupyter Book 1 was; Jupyter Book 2 simplified that stack on
  purpose.

### mdBook

- **Status:** Active, lightweight (Rust binary).
- **Markdown:** CommonMark, no MyST.
- **Navigation/search:** Book-style sidebar, search built in.
- **Theming:** Limited; mostly CSS overrides.
- **Maintenance:** Single binary, near-zero. Rust toolchain only needed
  for plugins; default install is download-and-go.
- **Executable code:** None natively (Rust-specific code playgrounds exist;
  not general).
- **GitHub Pages:** Standard.
- **Risk:** Designed primarily for Rust documentation; ecosystem is
  Rust-centric. Reader-friendly enough but lacks the rich-document features
  (cross-refs, citations, figures) DSM material may eventually want.
  Future-executable-code requirement is essentially closed off.

### GitBook

- **Status:** Proprietary SaaS; free tier limited.
- **Maintenance:** Hosted; lowest local maintenance but introduces vendor
  lock-in and pricing risk.
- **Risk:** Conflicts with the GitHub Pages requirement and the
  open-methodology positioning of DSM. Eliminated.

---

## Recommendation

**Adopt Jupyter Book 2** (MyST-based stack).

### Why it wins

1. **Project name alignment is also the right technical fit.** The original
   working assumption (Jupyter Book) was made before the v1 -> v2 (MyST)
   transition. The current v2 is *better* aligned with the requirements
   than v1 would have been: simpler stack (no Sphinx config), publication-
   grade defaults, native executable-code path for future use.

2. **MyST Markdown is the closest match to existing DSM_*.md files.**
   Superset of CommonMark; admonitions and cross-references upgrade
   gradually rather than requiring rewrite.

3. **Reader-friendly defaults out of the box.** Sidebar TOC, search,
   citations, figures all without custom theming. Matches "minimal
   maintenance" and "reader-friendly" simultaneously.

4. **Future executable code is a no-migration step.** Adding a notebook
   or executable cell to an existing book is config-only; no tool swap
   needed.

5. **Python toolchain matches the rest of the DSM ecosystem.**

### Why each alternative was rejected

- **MkDocs + Material:** Material's Nov 2025 maintenance freeze is a
  strategic risk over a multi-year horizon. Future executable-code
  requirement is also second-class.
- **Docusaurus:** Maintenance footprint (Node/React) too heavy for a
  single-author minimal-maintenance project; MDX adds preprocessing risk
  with existing GFM files.
- **Sphinx + MyST:** Reconstructs Jupyter Book 1's stack. Jupyter Book 2
  exists specifically to remove that complexity.
- **mdBook:** Reader-friendly but closes off future executable-code
  expansion; ecosystem is Rust-centric.
- **GitBook:** Vendor lock-in conflicts with the GitHub Pages requirement
  and open positioning.

### Open follow-ups (for R2 / R3)

- **R2 (sync mechanism):** Confirm a Jupyter Book 2 build action exists
  that can run on `repository_dispatch`; verify GitHub Pages deploy path.
- **R3 (best practices):** Verify performance on the largest DSM_*.md file
  (~7,800 lines) under MyST parsing.

---

## Sources

- [Top 5 open-source documentation tools in 2026 — hackmamba.io](https://hackmamba.io/technical-documentation/top-5-open-source-documentation-development-platforms-of-2024/) (notes Material maintenance mode, Nov 2025)
- [Towards Jupyter Book 2 with MyST-MD — executablebooks.org](https://executablebooks.org/en/latest/blog/2024-05-20-jupyter-book-myst/)
- [Jupyter Book 2 and the MyST Document Stack — SciPy Proceedings](https://proceedings.scipy.org/articles/hwcj9957)
- [Switching From Sphinx to MkDocs — Towards Data Science](https://towardsdatascience.com/switching-from-sphinx-to-mkdocs-documentation-what-did-i-gain-and-lose-04080338ad38/)
- [MkDocs vs Docusaurus for technical documentation — Damavis blog](https://blog.damavis.com/en/mkdocs-vs-docusaurus-for-technical-documentation/)
- [Material for MkDocs — Alternatives page](https://squidfunk.github.io/mkdocs-material/alternatives/)
- [Text in, docs out: Popular Markdown documentation tools compared — InfoWorld](https://www.infoworld.com/article/3526306/text-in-docs-out-popular-markdown-documentation-tools-compared.html)
- [MyST Markdown — Jupyter Book User Guide](https://jupyterbook.org/stable/get-started/create-content/)
