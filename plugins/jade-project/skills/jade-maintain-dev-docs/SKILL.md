---
name: jade-maintain-dev-docs
description: Govern development documentation by creating, continuing, reviewing, or closing change records; synchronizing architecture and current specifications with code changes; and maintaining decisions, handoffs, and historical migrations. Use for documentation governance, architecture documentation updates, change handoffs, and documentation acceptance checks; not for ordinary copyediting or generating a full documentation set for every code change.
---

# Maintain Development Documentation

Keep current rules discoverable, history traceable, and handoffs actionable. This skill provides a maintenance workflow, not the target project's architectural facts. Communicate in the user's language and write documents according to project conventions.

## 1. Identify Rules and Task Boundaries

- Read the applicable AGENTS.md, documentation guide, and existing indexes in the target project, if present, as entry points to project rules. Do not assume particular filenames, directories, identifiers, or checkers exist.
- Determine whether the task is review, editing, closure, or migration. For review-only tasks, report findings without editing documents. Code changes inform documentation impact; they do not authorize code edits or broader refactoring.
- Search related changes, current specifications, decisions, and architecture documents. Continue the existing record for the same concern before creating another. Without conventions, use one lightweight record for this task; design a directory structure and governance rules only when the user requests a governance system.
- Establish the relevant change range and verify it against working tree changes, specified commits, or user-provided materials. If the range is missing, inspect available material first; disclose gaps that affect conclusions and ask when necessary. Do not claim complete verification.

## 2. Assess Impact and Document Ownership

| Change | Action |
| --- | --- |
| Internal implementation adjustment without changes to documented behavior or contracts | Documentation edits can be skipped; report a specific reason |
| Local behavior, configuration, or domain rule change | Update the current specification or domain contract that owns the rule |
| Module responsibility, dependency direction, data contract, concurrency boundary, lifecycle, or cross-domain strategy change | Verify and update affected architecture contracts; change overviews and summaries only when topology, global invariants, or navigation changes |
| Added, moved, or deleted document or module entry point | Update affected indexes and references |
| Changed long-term tradeoff, alternative, or decision rationale | Record or extend a decision record according to project conventions |

Investigate uncertain boundaries rather than automatically expanding to a full documentation rewrite. Derive the needed document updates from the change; do not require every task to produce specifications, plans, decisions, and release notes.

## 3. Maintain Current Facts and Process Records

- Current specifications describe verified current behavior; change records hold goals, plans, progress, verification, and unresolved issues; decision records hold choices, rationale, consequences, and actual decision sources. Maintain release notes only when the task involves a release.
- When editing architecture documentation, read the architecture section of [Architecture and Migration Guide](references/architecture-and-migration.md); when migrating material, read its migration section.
- Every new or changed implementation contract must point to current evidence, such as a symbol and file path, or a file and line number. Tests and configuration can support corresponding claims. Old documentation is not proof that the current implementation has been verified.
- Requirements can describe intended behavior, but must identify what is unimplemented or unverified rather than mixing it into verified current facts. If implementation conflicts with specifications, report the discrepancy and establish whether the specification remains the intended requirement; do not legitimize a defect by changing documentation.
- Edit only affected content. Keep chat transcripts, phase progress, and task lists out of architecture contracts. Indexes contain navigation and necessary summaries; status belongs to the authoritative record designated by the project.

## 4. Handoff and Closure

Active change records retain confirmed conclusions, current progress, blockers and unknowns, next steps, and evidence entry points. Small tasks can keep these in one file without creating separate files for each heading.

Use existing project metadata and status vocabularies; without conventions, record only necessary information. Use actual dates for new records. Mark unknown historical dates explicitly instead of inventing them from file modification times. A decision reflected in code does not imply user approval; record implementation and approval evidence separately. Link the actual replacement when marking something superseded; if none exists, explain why work stopped rather than inventing a replacement relationship. Preserve the historical delivery facts of completed work.

Mark work complete only when in-scope delivery is complete, required verification has evidence, and blockers are resolved or explicitly handled under project rules. Passing documentation checks alone does not prove feature delivery; recording remaining issues does not automatically mean they have been accepted.

## 5. Verify and Report

- Use check commands that actually exist in the target project after confirming usage, working directory, and side effects. This skill includes no documentation checker and assumes no particular script or option is available.
- Check file links, anchors, indexes, status, and evidence locations affected by the change. Without a checker, inspect the affected scope directly and report coverage limits; do not report unexecuted automated checks as passing.
- Prefer stable anchors or symbol names for references; resolve relative links from the containing document. After moving files, check incoming and outgoing links, not just whether destination files exist.
- Distinguish existing issues from newly introduced issues. Do not hide new issues by expanding exclusions or resetting baselines.
- Report changed documents and reasons, or the specific reason no edits were needed; evidence for key claims; checks actually run and their results; unverified items and next steps. Distinguish structural checks, semantic verification, and runtime behavior validation.
