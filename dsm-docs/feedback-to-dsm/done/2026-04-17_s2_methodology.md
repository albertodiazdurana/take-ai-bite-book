# Methodology Observations — Session 2 (2026-04-17)

**Source:** dsm-jupyter-book
**Session:** 2
**Pushed:** 2026-04-17 (Session 2) to ~/dsm-agentic-ai-data-science-methodology/_inbox/dsm-jupyter-book.md

---

## Observation 1: Template 8 discoverability gap (creation-side)

**DSM section affected:** DSM_2.0 Module C §1 (Template 8: Sprint Plan with Cadence Guidance)
**Effectiveness score:** Low (structural compliance = 0 of 11 sections on a live sprint plan)

### What happened

At the end of Session 1 (2026-04-17), BL-002 Sprint 1 plan was authored and approved using an ad-hoc structure (Goal / Inputs / Exit criteria / Work items / Out of scope / Risks / Notes). Template 8, the canonical sprint-plan format in DSM_2.0.C §1, was not consulted.

The plan was approved through the 4-gate Pre-Generation Brief Protocol. Gate 1 (collaborative definition) confirmed scope, dependencies, and packaging of the 9 work items A-I. The content of the 9 items is substantively correct; the issue is structural: the plan document omits sections Template 8 requires, most notably the Sprint Boundary Checklist.

### Why Template 8 was not consulted

Trace of authoring context:
1. `dsm-docs/plans/README.md` was the reference the author consulted for plan format. It specifies minimum BL metadata (Status, Priority, Date Created, Origin, Author) and filename format, not sprint-specific structure.
2. Template 8 lives in `DSM_2.0.C_Sprint_Assessment_Templates.md`, a module loaded on-demand per the DSM 2.0 dispatch table. Nothing in the immediate authoring context (CLAUDE.md, plans/README.md, session transcript) pointed to it.
3. The 4-gate Pre-Generation Brief Protocol validates *content* (what is the artifact, why, how) but does not validate *format* (is the artifact shaped like the canonical template for its type).

### Score rationale

- **Discoverability:** Low. A sprint-plan author working from the plans folder has no signal that DSM_2.0.C §1 is the governing template.
- **Authoring compliance:** 0/11. None of Template 8's sections (beyond Goal, which is also in the minimum BL spec) were applied.
- **Approval-gate rigor:** Medium. Gate 1 caught substantive issues but not structural ones. This is a known gap, not a failure of the gate as designed; the gate was designed for content, not format.

### Proposed improvements

See backlogs.md proposals 1 and 2 for concrete tooling + documentation changes. The methodology-level takeaway is that **canonical templates living in on-demand modules need a discoverability path from the folder where the artifact is authored.** Template 8 in DSM_2.0.C is correctly located for on-demand loading, but `dsm-docs/plans/README.md` is where authoring decisions are made and is the natural pointer location.

---

## Observation 2: Exit criteria vs closure ritual conflation

**DSM section affected:** DSM_2.0 Module C §1 (Sprint Boundary Checklist)
**Effectiveness score:** Medium

### What happened

BL-002's closing Notes section says: *"Sprint 1 closes when exit criteria 1-6 are all met; at that point, this file moves to `dsm-docs/plans/done/`..."*

This conflates two distinct concepts that Template 8 and BACKLOG-362 separate:
- **Exit criteria:** Is the capability delivered? (functional test)
- **Sprint Boundary Checklist:** Is the closure properly recorded? (governance test — checkpoint, feedback, blog journal, README, next steps)

A capability can pass exit criteria without producing closure artifacts. BACKLOG-362's source incident (Graph Explorer S47) is exactly this: Sprint 16 Phase 1 was substantively complete but no formal closure was run. BL-002 would reproduce the same failure mode because its plan file does not contain the Boundary Checklist to tick against.

### Why this matters for methodology scoring

The conflation is linguistic: "closes" means both "is done" and "has been wrapped up" in natural English. Template 8's structure prevents the conflation by putting *Exit criteria* and *Sprint Boundary Checklist* in distinct sections. Ad-hoc plans that compress "done + wrapped up" into a single Notes paragraph lose that separation.

### Proposed improvements

Covered by backlogs.md Proposal 1 (Template 8 skeleton at creation prevents this by construction). Methodology-level note: the DSM glossary could add an explicit distinction between "sprint capability complete" (exit criteria) and "sprint closed" (boundary checklist ticked), to reinforce the separation in author language.

---

## Summary scores

| Aspect | Score | Notes |
|---|---|---|
| Template 8 discoverability from plans folder | Low | Not referenced in plans/README.md |
| Template 8 application in BL-002 | 0/11 sections | Ad-hoc structure used instead |
| Gate 1 rigor for sprint plans | Medium | Content validated, structure not |
| Exit criteria vs closure separation in plan language | Low | Conflated in Notes section |
| Remediation cost | Low | Two small proposals (tooling + docs) address root cause |
