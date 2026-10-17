---
name: jade-design-lightweight-project-docs
description: Design and establish a minimal development documentation structure for small libraries, tools, prototypes, short-lived projects, or applications with low collaboration overhead. Use to simplify documentation layouts and organize a README with necessary design and change notes; not for multi-domain long-term governance structures or copyediting alone.
---

# Design Documentation for Lightweight Projects

Make purpose, usage, essential design, and unfinished work discoverable while minimizing duplicate maintenance. Suitability depends on information volume and collaboration cost, not solely on language, platform, or developer count. Follow the user's language and existing project conventions. No other skill is required.

## 1. Choose the Minimum Scope

Read applicable AGENTS.md instructions, the repository README, and existing documents. Identify purpose, usage and verification methods, the current task, and any need for handoff across sessions. When the user only asks for advice, a plan, or a proposal, provide the structure in the reply and do not create, modify, delete, or move any file; touch files only when the user explicitly asks for setup or simplification. Without code or execution evidence, mark unknowns rather than inventing runnable commands.

Improve existing entry points first. If the README can hold the content clearly, no docs directory is needed. Do not rename or move a reasonable existing structure just to match a template.

## 2. Add Files as Needed

The following is an optional target-project layout, not a required generation checklist:

```text
README.md
docs/
├── README.md
├── architecture.md
└── changes/
    └── <short-name>.md
```

| File | When needed | Content boundary |
| --- | --- | --- |
| Repository README.md | Default entry point | Purpose, getting started, actually available verification methods, important limitations, and documentation links |
| docs/README.md | Enough documents exist to need separate navigation | Reading paths only; do not repeat the repository README |
| docs/architecture.md | Design, data flow, or boundaries cannot be explained concisely in the README | Current design and evidence; label plans explicitly and avoid reproducing source-code descriptions |
| docs/changes/<short-name>.md | A change worth retaining needs planning, verification, or handoff across sessions | One file for that change, not a record for every minor fix |

Create only files needed now with actual content. Do not generate empty directories, placeholder documents, annual hierarchies, separate task lists, or default ADR collections. Preserve existing filenames rather than requiring these names.

## 3. Keep Single-File Records Actionable

When a change record is needed, use one short document with the following sections that have actual content:

- Goals and scope: the problem and completion criteria.
- Approach and important tradeoffs: decisions and their basis; explicitly mark unresolved choices.
- Progress and next steps: completed work, blockers or unknowns, and the next actionable step.
- Verification and evidence: methods actually used, results, coverage gaps, and relevant implementation entry points.

Do not split every section into a file, copy chat transcripts, or present agent suggestions as user approval. At completion, update conclusions affecting usage or current design in the README or architecture document while retaining change history. Recording a plan does not mean implementation is complete.

## 4. Simplify and Expand

Before simplifying existing documentation, identify authoritative content and references. Merge or migrate only within the requested reorganization scope; delete or move existing files only when the user explicitly says so, and do not treat simplification as authorization to delete. Preserve historical facts and repair incoming and outgoing links. Matching headings do not prove duplicate content; a complex-looking directory is not a reason to delete files.

Suggest corresponding layers only when these actual needs appear, without expanding to a full system all at once:

| New need | Possible additional layer |
| --- | --- |
| Behavioral contracts across multiple domains need independent maintenance | Current specifications and domain architecture |
| Parallel contributors or repeated handoffs produce inconsistent rules | Documentation guide and change index |
| Important decisions and alternatives repeatedly need explanation | Decision records |
| One change's plan and verification have become difficult to read independently | A change directory with necessary split files |
| Actual independent releases and compatibility notes are needed | Release records organized by release unit |

A solo project can need a fuller structure, while a frontend or mobile application can remain lightweight. Explain recommendations through concrete maintenance problems; do not automatically migrate to a complex system without a user request.

## 5. Validate and Deliver

Check whether entry points expose necessary information, commands have supporting evidence, links and anchors work, duplicates are removed, and plans are distinct from facts. Run only applicable existing checks whose purpose has been confirmed. Mark checks not run as unverified.

Deliver the proposed or implemented layout, the need for each new file, actual edits and check results, and conditions for expansion. Creating no new files is a valid result; explain how existing documentation meets the need.
