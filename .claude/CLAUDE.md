@~/dsm-agentic-ai-data-science-methodology/DSM_0.2_Custom_Instructions_v1.1.md

<!-- BEGIN DSM_0.2 ALIGNMENT - do not edit manually, managed by /dsm-align -->
## 1. DSM_0.2 Alignment (managed by /dsm-align)

**Project type:** Application (DSM 4.0)
**Participation pattern:** spoke

### Session Transcript Protocol (reinforces inherited protocol)
- Append thinking to `.claude/session-transcript.md` BEFORE acting
- Output summary AFTER completing work
- Conversation text = results only
- Use Session Transcript Delimiter Format for every block:
  <------------Start Thinking / HH:MM------------>
  <------------Start Output / HH:MM------------>
  <------------Start User / HH:MM------------>
- HH:MM is 24-hour local time when the block begins; no end delimiter needed
- Append technique: read last 3 lines, use last non-empty line as anchor.
  NEVER match earlier content for mid-file insertion.
- Per-turn enforcement: a `UserPromptSubmit` hook in `.claude/settings.json`
  injects a reminder every turn. The hook enforces *occurrence*; the
  existing `validate-transcript-edit.sh` PreToolUse hook enforces *shape*.
  IDE monitoring and session-start behavioral activation are user
  affordances, not enforcement. The hook is the mechanism.
- Turn-boundary self-check: every turn begins with a transcript append. If
  your first tool call this turn was not a transcript append, the protocol
  was violated. This includes pure-reasoning turns (decision analysis,
  recommendation, trade-off comparison) that would otherwise touch no files,
  the transcript append is the one required tool call. The only exemption
  is content-trivial turns (one-word acknowledgments, single-fact
  confirmations with no new reasoning). Recover by appending a
  `[RETROACTIVE]` entry with the current HH:MM (never backdate) and a note
  explaining the gap; do not edit history.
- Process narration: thinking blocks narrate reasoning as it unfolds,
  including considered-and-rejected paths, doubts, loops, and reversals.
  Clean post-hoc summaries hide inefficiency signals that are the primary
  input to reasoning-efficiency analysis. Brevity is not the goal,
  auditability is.
- Unconditional activation: if `.claude/session-transcript.md` exists in
  the project, the protocol is active. No skill needs to activate it. The
  presence of the file is the activation signal. This rule is independent
  of `/dsm-go` Step 6 and applies to continuation sessions that defer
  from `/dsm-light-go` to `/dsm-go` mid-flight.
- Heredoc anti-pattern: when appending to the transcript via Bash, never
  use single-quoted heredoc (`<< 'EOF'`) if the content contains shell
  expansions like `$(date +%H:%M)`. Capture the timestamp into a variable
  first and use unquoted heredoc, or prefer the Edit-tool append path
  (read last 3 lines, anchor on last non-empty line).

### Pre-Generation Brief Protocol (reinforces inherited protocol)
- Four-gate model: collaborative definition (confirm threads → dependencies → packaging) → concept (explain) → implementation (diff review) → run (when applicable)
- Each gate requires explicit user approval; gates are independent
- What/why/how thinking block: before Gate 1, answer what the artifact is, why it is needed, and how it will be built, in the session transcript thinking block
- Skill self-reference: before claiming any behavior of a DSM skill (`/dsm-go`, `/dsm-wrap-up`, `/dsm-align`, etc.), read `scripts/commands/{skill-name}.md` or `~/.claude/commands/{skill-name}.md`. Do not answer "does skill X do Y?" from memory.

### Inbox Lifecycle (reinforces inherited protocol)
- After processing an inbox entry, move it to `_inbox/done/`
- Do not mark entries as "Status: Processed" while keeping them in place

### Actionable Work Items (reinforces DSM_3 planning pipeline)
- Only items in `dsm-docs/plans/` (and legacy `plan/backlog/`) are actionable work items.
- Material found elsewhere (`_reference/`, `docs/`, README, inbox, sprint plan drafts) is INPUT to the planning pipeline, not a substitute for it.
- Before suggesting implementation of anything that looks like a plan, verify that a formal BL exists in `dsm-docs/plans/`. If not, route through research → formalize → plan first.

### Punctuation
Use "," instead of "—" for connecting phrases in any language.

### Code Output Standards (reinforces Earn Your Assertions)
- Show actual values: shapes, metrics, counts, paths
- No generic confirmations: avoid "Done!", "Success!", "Data loaded successfully!"
- When uncertain, state the uncertainty; do not guess or fabricate
- Read the relevant source (file, definition, documentation) before answering questions about it; do not answer from partial knowledge
- Let results speak for themselves

### Tool Output Restraint (reinforces Take a Bite)
- Generate only what you can meaningfully process in the next step
- Comprehensive tool reports are reference material, not the analysis itself
- Run tools because the output serves the task, not because the tool is available

### Working Style (reinforces Take a Bite, Critical Thinking)
- Confirm understanding before proceeding
- Be concise in answers
- Do not generate files before providing description and receiving approval

### Cross-Repo Write Safety (reinforces Destructive Action Protocol)
- First write to any path outside this repository in a session requires explicit user confirmation
- Present the content and target path before writing; do not write cross-repo silently
- Subsequent writes to the same cross-repo target in the same session do not need re-confirmation

### Plan Mode for Significant Changes (reinforces Earn Your Assertions)
- Before implementing significant features: explore codebase, identify patterns, present plan
- Do not write or edit files until the plan is approved by the user
- This is a read-only exploration phase, not an implementation phase

### Session Wrap-Up (reinforces Know Your Context)
- When the user says "wrap up" or the session ends, use `/dsm-wrap-up`
- Before wrap-up, cross-reference sprint plan if one exists (verify all deliverables accounted for)
- At minimum: commit pending changes, push to remote, update MEMORY.md
- Create a handoff document if complex work remains pending
<!-- END DSM_0.2 ALIGNMENT -->

# Project: DSM Jupyter Book

## Quick Reference

### Common Commands
- `cd book && mystmd build` - Build the book locally (Sprint 1+)
- `gh workflow run scheduled-build.yml` - Manual build+deploy trigger

### Key Paths
- Upstream (public mirror, what the book renders): `~/dsm-take-ai-bite`
  (git: `github.com/albertodiazdurana/take-ai-bite`)
- DSM Central (private methodology hub, governance only, not rendered):
  `~/dsm-agentic-ai-data-science-methodology`
- Book source: `book/` (MyST engine config in `book/myst.yml`)
- Build output: `book/_build/` (generated by `myst build`)
- Copied content: `book/content/` (gitignored, populated per build)
- Pipeline scripts: `scripts/`

### Book Content (from take-ai-bite root, the public mirror)
- Core: DSM_*.md files (35 methodology documents)
- Community: README.md, CONTRIBUTING.md, CODE_OF_CONDUCT.md, CHANGELOG.md
- Public-facing extras: FEATURES.md, LICENSE-DOCS.md, SECURITY.md, TAKE_A_BITE.md
- LICENSE (plain text, no .md) is linked from the site footer, not copied

## Document References
- Research Phase: Section 2.1.9 (Business Understanding)
- Phase 0.5: Research and Grounding
- Gateway Review: Section 6.5

## Author
**Alberto Diaz Durana**
[GitHub](https://github.com/albertodiazdurana) | [LinkedIn](https://www.linkedin.com/in/albertodiazdurana/)

## Project Type
Application (DSM 4.0). The project is a Node.js build pipeline that clones
the upstream `take-ai-bite` repo (public mirror of DSM Central) at a tagged
release, runs MyST to build a documentation site, and deploys it to GitHub
Pages. Tracked artifacts are code (`scripts/`, workflows, `book/myst.yml`,
`package.json` + lockfile); tracked content is governance (`dsm-docs/`). The
built markdown content (`book/content/`) is gitignored and ephemeral per
build.

**Two upstreams, two roles.** DSM Central (private) is the methodology hub
that governs this project's workflow (protocols, skills, feedback routing).
take-ai-bite (public) is the rendering source: the curated subset of Central
content that Alberto chooses to publish. The book renders take-ai-bite; the
agent obeys Central. Feedback files in `dsm-docs/feedback-to-dsm/` and inbox
pushes go to Central, not take-ai-bite.

**Classification override rationale.** DSM_0.2 §17 Project Type Detection
table relies on Python-convention filesystem signals (`src/`, `tests/`,
`app.py`) and classifies this repo as "Documentation (DSM 5.0)" when those
are absent. That auto-detection is incorrect here because:

1. DSM 5.0 explicitly excludes environment setup (`DSM_5.0...` §1 line 44-47),
   but this project REQUIRES a Node.js environment (package.json + lockfile
   + mystmd).
2. The project's deliverable is a running build pipeline + deployed site, not
   a set of markdown files. Version control tracks code changes (scripts,
   workflows, myst.yml), not content changes.
3. Sprint 1 creates `scripts/` with 3 production bash scripts (`copy-
   central-content.sh`, `check-central-version.sh`, `inject-version.sh`),
   `.github/workflows/` with build+deploy automation, and an end-to-end
   test (item G). These are Application signals, just not Python-flavoured.

This override survives `/dsm-align` runs: if the auto-detector re-flags DSM
5.0 because `src/` is absent, treat that as a known false positive and keep
the override in place. Feedback to DSM Central is filed separately (Session
2 methodology observation) proposing broader detection signals.

Applicable methodology:
- DSM 4.0 App Development Protocol for `scripts/` and build pipeline
- DSM 2.0 Template 8 for sprint planning (see BL-002)
- DSM 1.0 Phase 0.5 retained as project origin (Session 1 research closure)
- DSM 5.0 conventions apply to the BUILT site's content (file naming,
  cross-references), but the built content is not tracked in git

## Current Phase
Phase 0.5: Research and Grounding

## Key Requirements
- Auto-sync when take-ai-bite tags are pushed (Central mirrors the tags to
  take-ai-bite as part of the publish workflow)
- Reader-friendly navigation and formatting
- Minimal maintenance overhead

