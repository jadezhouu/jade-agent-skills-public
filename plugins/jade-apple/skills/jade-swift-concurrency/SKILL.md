---
name: jade-swift-concurrency
description: Implement, debug, or review Swift concurrency code involving actor isolation, Sendable diagnostics, task cancellation and lifetime, callback-to-async bridging, or Swift 6 migration in macOS, iOS, and watchOS projects. Do not trigger for layout-only edits or synchronous logic without concurrency concerns.
---

# Swift Concurrency

Trace the relevant calls to identify who owns mutable state, which values cross isolation domains, and who ends each task. For diagnostics, obtain the exact error and declarations; for version-sensitive decisions, inspect the actual toolchain, language mode, default isolation, and upcoming feature settings. Compiler version, language mode, and deployment target are distinct; do not infer configuration from project age. Inspect the repository first and ask only for missing information that affects the current fix.

## Core decisions

- **Isolation and execution**: `async`, `await`, and `Task {}` do not guarantee moving computation off the main actor. A `Task` can inherit actor isolation where it is created; do not switch to `@concurrent` merely because no UI work precedes the first `await`. Asynchronous waiting itself does not occupy the main actor; choose an execution boundary for actual expensive synchronous computation and verify transferred values are safe.
- **Reentrancy and ordering**: An actor serializes access to isolated state, but an operation spanning `await` is not a transaction and tasks need not complete in creation order. Revalidate business assumptions after resumption; use request identity where appropriate to prevent stale results overwriting newer results in operations such as search. Do not prohibit all state changes after `await`.
- **Transfer safety**: Prefer appropriate state ownership or immutable snapshots. `Sendable` does not make arbitrary shared variables safe, and `sending` does not mean the type conforms to `Sendable`. Do not blanket-apply `@MainActor`, `@unchecked Sendable`, or `nonisolated(unsafe)` to silence diagnostics; explain the actual synchronization invariant and scope of any escape hatch, and the exit condition for migration exemptions.
- **Task ownership**: Prefer structured relationships for work the caller must await and cancel. Both `Task {}` and `Task.detached` are unstructured and do not automatically receive parent cancellation; define how results, errors, and stopping are handled. Do not introduce detached tasks merely for “background execution.”
- **Cancellation and lifetime**: Cancellation is cooperative; it does not guarantee underlying work stops or stale results cannot commit. Do not swallow sleep cancellation errors and continue a loop; check that work remains valid when committing results. Define who cancels long-lived tasks and when captures are released. Promoting `[weak self]` to a strong reference before a long wait still extends lifetime; relying on `deinit` cannot break a cycle that prevents it from running.

## Read as needed

- For Swift 6 migration, execution of `nonisolated async`, `sending`, or isolated protocol conformances, read [Isolation and migration](references/isolation-and-migration.md).
- For early task-group returns, continuations, event streams, or concurrency tests, read the relevant sections of [Cancellation, bridging, and verification](references/lifecycle-and-bridging.md).

## Verification and delivery

Preserve existing architecture, deployment targets, and test frameworks; fix only boundaries relevant to the request. Verify cancellation, out-of-order completion, failure, and release paths according to risk; compilation does not prove freedom from business-level races. Apple build and runtime checks need an appropriate macOS/Xcode/SDK environment; report unverified items when unavailable. Performance conclusions require measurement, not assumptions based on adding actors, reducing awaits, or using detached tasks.

For implementation tasks, edit the relevant code; for reviews, report location, trigger, impact, and the smallest fix. State the checks actually performed and follow the user's language and project output conventions.
