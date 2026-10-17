---
name: jade-design-maintained-project-docs
description: Design, establish, or adapt development documentation structures for continuously maintained projects with multiple domains or recurring human and agent handoffs. Use for documentation layout, responsibilities, authoritative sources, and expansion rules across frontend, mobile, backend, and library projects; not for routine documentation updates or minimal layouts for lightweight projects.
---

# Design Documentation for Maintained Projects

Organize documentation for long-term maintenance, separating current facts, change history, and decision rationale. Follow the user's language and project conventions. This skill works independently without other skills or checking scripts.

## 1. Establish Scope

Read applicable AGENTS.md instructions, existing documentation guides, directories, and representative documents. Identify modules, collaboration patterns, release units, and existing problems. Long-term maintenance does not imply many files: multiple domains, concurrent changes, long-lived contracts, or repeated handoffs justify additional layers.

Determine whether the user wants a proposal or an implemented structure. When the user only asks for a proposal, plan, or design, provide it in the reply and do not create, modify, delete, or move any file. Touch files only when the user explicitly asks for setup or reorganization: for setup, create documents supported by available content; for reorganization, first map old locations to new ones, and delete or move existing files only when the user explicitly says so. Structure design does not authorize deleting history, changing code, or rewriting all documents.

If context is missing, state assumptions and propose an adjustable minimal layout. Seek clarification only for unknowns affecting authoritative sources or safe migration. Lightweight projects need not use every layer; explain which layers can be omitted.

## 2. Assign Document Responsibilities

The following is a reference layout in the target project, not this skill's resource directory or a checklist to create all at once. Preserve existing names and capitalization.

```text
docs/
├── README.md
├── documentation-guide.md
├── architecture.md
├── architecture/
├── specs/
├── changes/
│   └── <change-id>/
│       └── README.md
├── decisions/
└── templates/
```

| Location | Authoritative content and creation condition |
| --- | --- |
| README.md | Navigation, reading order, and layer responsibilities; do not duplicate all statuses |
| documentation-guide.md | Ownership, naming, status, update, and acceptance rules; create for ongoing collaboration without duplicating AGENTS.md rules |
| architecture.md | Current topology, core boundaries, and domain entry points; facts need implementation evidence, while target designs need explicit labels |
| architecture/ | Domain architecture that cannot fit clearly in the overview; split by business or technical responsibility, not by mechanically copying source directories |
| specs/ | Maintained behavior, interfaces, and constraints; explicitly distinguish intended requirements from implemented behavior |
| changes/ | Goals, implementation process, verification, handoff, and unresolved issues for an individual change |
| decisions/ | Choices, alternatives, rationale, and consequences worth retaining; do not create empty ADRs without actual decisions |
| templates/ | Repeated, stable record formats; establish a real need before extracting templates |

Assign one authoritative location to each kind of information. A change-local spec describes that change's goals; specs holds maintained specifications. At closure, synchronize verified new behavior into specifications while retaining the change's historical context. Architecture describes organization; specifications describe behavioral requirements. Connect them with links rather than duplicating complete rules.

## 3. Expand with Complexity

- Default to one README per change containing goals and scope, approach, execution status, verification, and handoff. Split out spec.md, plan.md, tasks.md, verification.md, or reviews/ only when content needs independent reading and maintenance.
- Do not pre-create empty files or skeletons: create decisions/, releases/, templates/, changes/index.md, or similar only after real content exists; extract a template only after the same format has repeated.
- Add changes/index.md or yearly grouping when records become difficult to find. Preserve existing identifiers; otherwise use readable, unique identifiers without requiring a CHG prefix. Index status should link to or be generated from the authoritative record.
- For substantial architecture material, add an optional quick-reading summary containing only boundaries, global invariants, and navigation. Do not duplicate detailed architecture. An existing Architecture-Assistant.md name can be retained, but agent-specific documents and fixed length budgets are not required.
- Add Assistant-Index.md only when a map of code entry points and reusable capabilities has distinct value; otherwise include it in the documentation entry point. Do not maintain two indexes with the same responsibility.
- Add releases when release records are needed, organized by actual independently released units. Frontend applications, SDKs, or services can also release independently; Apple platforms released together need not be separated.
- In a monorepo, keep cross-package rules at repository level and local specifications near their owning applications or packages, linked from top-level navigation. Do not copy the same contract into every package.

## 4. Propose and Implement as Requested

Provide the recommended layout, each file's responsibility, why it is needed, when it changes, and layers deferred for now. During implementation, organize entry points and authoritative rules first, then place known content appropriately. Mark architecture claims without code evidence as awaiting verification; do not invent implementation facts or decisions.

When migrating existing material, record mappings, update incoming and outgoing links, and preserve historical meaning. Do not guess when same-named destinations are ambiguous. Do not move files solely because of naming preferences. Preserve existing working tree changes and explain conflicts that cannot be merged safely.

If templates are needed, create only those required by the project: change records contain scope, status, implementation, verification, unknowns, and next steps; decision records contain context, options, decisions, consequences, and actual decision sources. Follow project conventions for status, dates, and approval fields; do not prefill fictitious completion or approval.

## 5. Validate

Check that each information category has one authoritative source, entry points are discoverable, relative links and anchors work, current facts are distinct from history, and no empty files lack a purpose. Confirm usage before running an existing project checker; without one, inspect the affected scope and state limitations.

Deliver the layout and responsibilities, actual edits, migration mappings if any, checks performed, and unverified content. Establishing directories does not mean all documentation has been verified or features are complete.
