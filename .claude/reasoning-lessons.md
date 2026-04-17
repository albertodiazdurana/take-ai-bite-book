# Reasoning Lessons

Per-session lessons extracted from session transcripts. Appended by
the wrap-up skill at each session end. See DSM_0.2 Module A Reasoning
Lessons Protocol for the extraction rules.

Categories: [pattern], [ecosystem], [infrastructure], [skill], [methodology]

- [auto] S1 [pattern]: Pre-Generation Brief Protocol respected by deferring web-search execution until user approved BL-001 scope. Stopping at "gate 1 (collaborative definition)" instead of doing all four research threads in one turn prevented speculative output and kept scope under user control.
- [auto] S1 [pattern]: Scope-narrowing questions from the user (e.g., "all md files in root folder") should prompt an EXPLICIT scope-rule artifact update rather than just verbal acknowledgment. Codified the "flat *.md glob, no recursion" rule into R4 and Decision 0003 — survives into implementation without re-asking.
- [auto] S1 [pattern]: Bundled recommendations across multiple open items (R4 Q1a/Q2/Q4 + R3 promotion) close decision loops faster than asking each item individually. Format: one sentence per item with load-bearing reason + trade-off, closing with single accept/revise gate.
- [auto] S1 [infrastructure]: BL-370 rename-staging hook fired correctly on R1-promotion commit. The bug was that I edited the R1 file AFTER `git mv`, so index and working tree diverged. Fix: do Edit → git mv → git add moved-path (single atomic stage of rename+content) → commit. Applied successfully on the R2, R4, and BL-002-approval commits.
- [auto] S1 [methodology]: Not every research thread needs a Decision artifact. R3 items were implementation guidelines (theme name, search choice, file layout), not architectural choices. Skipped promotion; research file stays as the source-of-truth; "verify-in-implementation" markers become BLs at implementation time, not decisions now.
- [auto] S1 [project]: Declared project type in CLAUDE.md ("Hybrid: DSM 1.0 + DSM 4.0") was conflating methodology usage with project structure. Filesystem signals (no notebooks/, no src/, markdown-only jupyter-book) actually matched Documentation (DSM 5.0). Fixed by splitting the two concepts in the CLAUDE.md section.
- [auto] S1 [pattern]: When user asks "what do you recommend?" across multiple open items, consolidate into a bundled recommendation with (item, recommendation, load-bearing reason, trade-off) per line. Closing the bundle with "accept all or call out which to revise" converted 4 separate approvals into 1 round-trip.
