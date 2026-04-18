### [2026-04-18] DSM Central BL-376 implemented: release tags will mirror to TAB

**Type:** Notification
**Priority:** Medium
**Source:** DSM Central (dsm-agentic-ai-data-science-methodology, session 193)

DSM Central shipped BL-376 (Mirror Central Release Tags to TAB on /dsm-version-update). Starting with the next Central release, `vX.Y.Z` tags will be pushed to dsm-take-ai-bite (TAB) at TAB's sync commit as part of the version-update workflow.

**What this means for dsm-jupyter-book:**

- After the next Central version bump, TAB will have a matching `vX.Y.Z` tag at the sync commit on TAB's main.
- If dsm-jupyter-book fetches from a TAB upstream: `git fetch <tab-remote> --tags` will pull the tag locally.
- `git checkout vX.Y.Z` then resolves to the sync snapshot.

**Tag semantics (important):** The tag on TAB points to TAB's sync commit, not to Central's release commit. TAB commit history is separate from Central's. If dsm-jupyter-book mirrors from TAB, expect the same semantic: the tag marks the downstream sync point of the release, not a 1:1 commit equivalent to Central.

**Historical tags:** Central has 29 existing tags (v1.3.0 through v1.5.2). Backfill is out of scope; only v1.5.3 onward will propagate. CHANGELOG.md in TAB remains the full history record.

**Action required here:** None until the next Central release. When that release lands, dsm-jupyter-book's refresh-from-TAB flow will expose the tag.

**References:**
- BL file (DSM Central): `dsm-docs/plans/BACKLOG-376_mirror-central-release-tags-to-tab.md` (moving to `done/` shortly)
- New skill step: `/dsm-version-update` Step 4b
- Related: BL-373 (mirror clone bootstrap), BL-374 (skill-file testing protocol), BL-236g (mirror sync manifest)