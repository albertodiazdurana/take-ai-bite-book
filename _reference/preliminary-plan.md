# DSM Jupyter Book - Preliminary Plan

**Date:** 2026-02-05
**Status:** Draft (pending research)
**Project Type:** Hybrid (DSM 1.0 research + DSM 4.0 tooling)

---

## 1. Project Goal

Create a reader-friendly documentation site from TAB (central dsm mirror) methodology, automatically synced when new versions are tagged.

**Original motivation:** Make DSM methodology more accessible and navigable for users, beyond raw markdown files: /home/berto/dsm-agentic-ai-data-science-methodology/plan/backlog/developments/BACKLOG-052_dsm-jupyter-book.md

**Future consideration:** May add executable code examples as interactive documentation.

---

## 2. Book Content (from TAB mirror repo root)

### Core Methodology
- all DSM_ files

### Community Documents
- README.md
- CONTRIBUTING.md
- CODE_OF_CONDUCT.md
- CHANGELOG.md
- LICENSE

---

## 3. Key Requirements

| Requirement          | Description                                           |
| -------------------- | ----------------------------------------------------- |
| Auto-sync            | Triggered when DSM Central pushes a new tag           |
| Reader-friendly      | Clear navigation, table of contents, search           |
| Minimal maintenance  | No manual intervention after initial setup            |
| GitHub Pages hosting | Free, integrated with GitHub                          |
| Future-proof         | Support for executable code/notebooks if needed later |

---

## 4. Research Questions

Before finalizing the plan, research needed on:

1. **Tool selection: Does Jupyter Book make sense?**
   - Jupyter Book strengths and limitations
   - Alternatives: MkDocs, Docusaurus, Sphinx, mdBook, GitBook
   - Comparison criteria: markdown support, navigation, search, theming, maintenance
   - Best fit for pure-markdown now, with potential for executable notebooks later
   - Which tools support interactive/executable code?

2. **Selected tool setup** (after decision)
   - Configuration options
   - Markdown compatibility with existing DSM files
   - Custom styling options

3. **Cross-repo sync mechanism**
   - GitHub Actions: repository_dispatch vs workflow_dispatch
   - How to trigger build from DSM Central tag push
   - Alternatives to consider (git submodules, direct fetch)

4. **Best practices**
   - Multi-source documentation patterns
   - Version display in built site
   - Handling large markdown files (~7,800 lines)

---

## 5. Preliminary Architecture

```
TAB (source)              dsm-jupyter-book (builder)
+------------------------+        +------------------------+
| DSM_*.md files         |  tag   | .github/workflows/     |
| README, CONTRIBUTING   | -----> |   build.yml            |
| CHANGELOG, LICENSE     |        | content/               |
+------------------------+        |   config files         |
                                  |   (fetched content)    |
                                  +------------------------+
                                           |
                                           v
                                  +------------------------+
                                  | GitHub Pages           |
                                  | (published site)       |
                                  +------------------------+
```

---

## 6. Open Questions

- [ ] Which documentation tool is best fit? (Jupyter Book vs alternatives)
- [ ] Should content be copied or fetched at build time?
- [ ] How to handle DSM version in site title/footer?
- [ ] Should case-studies/ be included?
- [ ] Build on every tag or only release tags (vX.Y.Z)?

---

## 7. Next Steps

1. Conduct online research (Phase 0.5)
   - Tool comparison (Jupyter Book, MkDocs, Docusaurus, etc.)
   - Cross-repo sync patterns
   - Best practices for markdown documentation sites
2. Document findings in docs/research/
3. Finalize plan based on research
4. Setup environment and begin implementation

---

## 8. Methodology and Feedback

This project follows DSM methodology:
- **Research:** DSM 1.0 Phase 0.5 (Research and Grounding)
- **Development:** DSM 4.0 (Software Engineering Adaptation)
- **Documentation:** Per DSM standards (checkpoints, decisions, blog)

**Feedback to DSM Central:**
- Track methodology gaps and improvements in `docs/feedback/`
- Submit findings via Gateway Review Protocol
- Contribute learnings back to central DSM

---

**Author:** Alberto Diaz Durana 
