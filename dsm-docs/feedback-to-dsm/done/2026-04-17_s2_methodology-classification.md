# Methodology Observations — Session 2 (2026-04-17, supplement)

**Source:** dsm-jupyter-book
**Session:** 2 (second batch, after reclassification discovery)
**Pushed:** 2026-04-17 (Session 2 supplement) to ~/dsm-agentic-ai-data-science-methodology/_inbox/dsm-jupyter-book.md

---

## Observation 3: Project Type Detection table is Python-biased

**DSM section affected:** DSM_0.2 §1 / DSM_0.2.A §17 (Project Type Detection)
**Effectiveness score:** Medium (miscategorises an entire class of projects)

### What happened

This project (dsm-jupyter-book) was classified as **Documentation (DSM 5.0)** by filesystem-signal detection in Session 1, then corrected to **Application (DSM 4.0)** in Session 2 after the user challenged the classification. The miscategorisation had cascading consequences: the install-path discussion for Sprint 1 item A treated the environment question as optional (per DSM 5.0's explicit exclusion of environment setup), until the user asked "we would need an environment."

### Why the detection table missed this

Current DSM_0.2.A §17 Project Type Detection table:

| Signal | Type | Track |
|--------|------|-------|
| `notebooks/` only, no `src/` | Notebook (Data Science) | DSM 1.0 |
| `src/`, `tests/`, `app.py` | Application | DSM 4.0 |
| Both `notebooks/` and `src/` | Hybrid | DSM 1.0 + 4.0 |
| `dsm-docs/`, markdown-only, no `notebooks/` or `src/` | Documentation | DSM 5.0 |
| `{contributions-docs-path}/{project}/` exists | External Contribution | DSM_3 §6.6 |

All Application signals (`src/`, `tests/`, `app.py`) are Python conventions. A Node.js, Rust, Go, or bash-based application produces none of these signals and falls into the Documentation (DSM 5.0) bucket by default, because the table's Documentation branch is "no `notebooks/` or `src/`" — the signal is the *absence* of Python code, not the *presence* of documentation intent.

The failure mode is a false-positive Documentation classification for any non-Python application project. This is especially consequential because DSM 5.0 explicitly excludes environment setup (DSM_5.0 §1 line 44-47), meaning a misclassified Node/bash/Rust project inherits a methodology that says "no environment needed" when in fact it needs one.

### Evidence chain

1. Session 1 `/dsm-align` detected filesystem signals: `dsm-docs/` present, no `notebooks/`, no `src/` → Documentation (DSM 5.0).
2. CLAUDE.md "Project Type" section was written: *"Documentation (DSM 5.0). The project structure is markdown-only..."*
3. Session 2 Sprint 1 execution revealed the miscategorisation when the install path for mystmd (Node.js dependency) surfaced. DSM 5.0 says environment setup doesn't apply; reality says we need a package.json and lockfile.
4. User caught the contradiction: "we would need an environment. also this project was incorrectly classified as type 'Documentation dsm_5'."
5. Session 2 reclassified to Application (DSM 4.0) via explicit override in CLAUDE.md (outside alignment delimiters) because the detection table will continue to auto-flip to DSM 5.0 on every `/dsm-align` run until `src/` physically exists.

### Proposal

Three complementary changes to the Project Type Detection table and related protocols:

**1. Broaden Application signals.** Treat the following as Application signals, in addition to the current Python-specific ones:

- `package.json` at repo root (Node.js)
- `Cargo.toml` (Rust)
- `go.mod` (Go)
- `pyproject.toml` or `setup.py` (modern Python)
- `.github/workflows/` containing a build/deploy job (any language)
- `scripts/` directory with executable scripts (any shell) as a secondary signal

If any of these are present (or explicitly declared as planned), classify as Application even without `src/`.

**2. Support declarative override.** If a project has a reasonable structural mismatch between current filesystem state and intended project type (e.g., Sprint 1 has not yet created `scripts/` and `package.json`, but the sprint plan calls for them), allow CLAUDE.md project-specific section to declare an explicit override with rationale. `/dsm-align` should respect the override and skip regenerating the `**Project type:**` line inside the alignment delimiters if the project-specific section has a `## Project Type` block stating an override.

**3. Flag "Documentation but with pipeline" as a distinct pattern.** Projects like this one (build pipeline whose output is documentation) sit between DSM 4.0 and DSM 5.0: code conventions apply to the pipeline, documentation conventions apply to the built site content. This is not the existing "Hybrid (DSM 1.0 + 4.0)" pattern. Consider adding a "Build Pipeline for Documentation" project type or an explicit layering protocol so the two governance domains (pipeline code vs built content) are documented.

### Related to

- Backlog proposals in `2026-04-17_s2_backlogs.md` (already pushed) address sprint-plan structural validation at creation time. This observation is complementary: project-type validation at creation/alignment time.
- BACKLOG-362 (Sprint Boundary Gate) also assumes correct project-type classification to generate the right template block.

---

## Summary score

| Aspect | Score | Notes |
|---|---|---|
| Detection-table coverage of non-Python applications | Low | All Application signals are Python conventions |
| Recovery path for misclassified projects | Low | No declarative-override mechanism; `/dsm-align` will re-miscategorise each run |
| DSM 5.0 vs DSM 4.0 boundary when documentation is built by a pipeline | Unclear | No existing protocol for layered projects |
| Remediation cost | Low | Signal table is short; adding 5-6 file-presence checks is mechanical |
