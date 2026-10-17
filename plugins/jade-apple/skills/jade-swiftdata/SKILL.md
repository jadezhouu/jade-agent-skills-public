---
name: jade-swiftdata
description: Implement, debug, or review SwiftData models, queries, saving, concurrency, and schema migrations in macOS, iOS, and watchOS persistence tasks. Do not trigger for SwiftUI layout-only changes or other storage technologies.
---

# SwiftData

Establish the target platforms, minimum OS versions, Xcode/Swift versions, store configuration, and whether CloudKit is enabled. Follow the project architecture; do not raise deployment targets just to use a new API. Inspect project configuration first when context is incomplete, and ask only for missing information that affects the current decision.

## Core decisions

- **Save boundaries**: Autosave does not promise that an operation is durably stored. Explicitly call `save()` and handle failure when an operation requires confirmation of persistence; do not assume a background context inherits the main context's autosave configuration. Do not hide failed user writes with `try?`.
- **Concurrency boundaries**: Use contexts and their managed models within their owning isolation domains; do not share mutable models between concurrent tasks. Pass value snapshots or `PersistentIdentifier` across actors and fetch again in the receiving context; save successfully before relying on persistent identity, and do not parse ID internals. Consider `@ModelActor` for background storage operations; `Task {}` does not automatically leave the main actor.
- **Relationship semantics**: Establish ownership, sharing, and the expected state after deletion before choosing inverses, optionality, and delete rules. The default `.nullify` is not inherently wrong; use `.cascade` only when child objects should be destroyed with their parent. Declare inverses explicitly where needed to remove ambiguity; do not change all relationships to cascade deletion.
- **Query boundaries**: A compiling `#Predicate` does not prove that the store backend can execute it. Ordinary Swift expressions or successful in-memory `Predicate.evaluate` calls do not establish database support; computed and `@Transient` properties are not persistent query fields. Validate filtering over complex relationships, optionals, and Codable internals on the target OS and store configuration.
- **Refresh semantics**: Use `@Query` for SwiftUI view updates; use `ModelContext` fetches in service code and define when to refetch. Neither `fetchCount()` nor ordinary fetches automatically become live subscriptions.
- **Existing data**: Before changing a schema, identify released versions and data that must survive. Consider migration for renames, type changes, uniqueness, and relationship changes; verify upgrades using copies of old stores instead of deleting stores to resolve migration errors. Use `VersionedSchema` / `SchemaMigrationPlan` as evolution requires, without imposing a full migration system on simple prototypes.

## Read as needed

Only for CloudKit, query performance, or model inheritance, read the relevant section of [Conditional constraints](references/conditional-guidance.md). Do not introduce a feature merely because the SDK supports it.

## Validation and delivery

Choose validation for the change: reopen the store after saving, inspect relationships after deletion, execute actual fetches, upgrade an old schema, or check cross-device sync. Validate query and migration problems using isolated copies of disk stores; passing in-memory container tests alone does not establish disk-store behavior.

Distinguish macro compilation, store execution, and synchronization validation. Apple build and runtime checks require macOS/Xcode/SDK support for the target platform; identify unverified items when the environment is insufficient. Without a reproduction or applicable version evidence, mark suspected framework defects as unverified rather than claiming an expression crashes on every version.

Report only supported review findings, with location, triggering conditions, impact, and a minimal fix; for implementation requests, edit the relevant code directly. Follow the user's language and project output conventions by default.
