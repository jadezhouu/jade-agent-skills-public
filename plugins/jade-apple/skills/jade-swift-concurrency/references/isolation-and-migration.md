# Isolation and migration

Read only when the diagnostic or migration involves these semantics; do not proactively change project-wide concurrency settings.

## Versions and execution semantics

- Check the Swift/Xcode toolchain, Swift language mode, strict concurrency, default actor isolation, flags such as `NonisolatedNonsendingByDefault`, and dependency module settings separately. Inspect actual build arguments and configuration inheritance; `swift-tools-version` alone does not establish language mode. Do not treat lowering checking levels as a fix for Swift 6 mode's strict checks.
- SE-0461 / SE-0466 were implemented in Swift 6.2; “Xcode 16+” is not proof of support. Default main-actor isolation and caller-isolation inheritance for nonisolated async functions are separate settings; a new compiler does not imply both are enabled.
- With `NonisolatedNonsendingByDefault` enabled, otherwise unannotated nonisolated async functions inherit caller isolation; supported toolchains can express this explicitly with `nonisolated(nonsending)`. The older semantics execute on the generic executor. `@concurrent` explicitly leaves the caller's actor for work that needs to move off it; it does not promise a particular thread.
- Isolation inheritance is not dynamic call-stack propagation: a `Task {}` created inside a nonisolated function cannot be assumed to inherit the caller's actor merely because the function currently runs on that actor. Inspect the closure's declaration context, isolated parameters, and captures.

## Repair boundaries

- `sending` and region-based isolation can allow transfer of non-Sendable values no longer accessed by the original isolation domain; check aliases and uses after transfer rather than substituting a keyword for ownership analysis. `[weak self]` also does not make unsafe cross-isolation access safe.
- When protocol requirements and implementation isolation disagree, establish where callers need the conformance. Consider isolated conformances when supported, but account for their restriction on where the conformance can be used; do not force methods accessing isolated state to be `nonisolated`.
- `@preconcurrency` does not guarantee thread safety; `MainActor.assumeIsolated` asserts existing isolation rather than hopping executors. Do not substitute thread IDs or main-thread checks for isolation evidence.
- Actors do not replace framework queue contracts. For example, access a Core Data background context through its `perform` entry points or equivalent; transfer usable object IDs or value snapshots across contexts and refetch, rather than sharing managed objects merely because an actor wraps them.
- Migrate incrementally by related modules and diagnostics, preserving behavior and checking compilation. Do not incidentally replace Combine, test frameworks, locks, or architecture. An async declaration without `await` can serve a protocol or execution semantics; do not add fake waits for lint.

## Verified sources

Checked against official proposals on 2026-10-16; use the target toolchain to establish exact syntax and availability.

- [SE-0461: Async function isolation](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0461-async-function-isolation.md)
- [SE-0466: Default actor isolation](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0466-control-default-actor-isolation.md)
- [SE-0430: Sending parameters and results](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0430-transferring-parameters-and-results.md)
- [SE-0470: Isolated conformances](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0470-isolated-conformances.md)
- [Core Data: Concurrency](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/Concurrency.html)
- [SE-0306: Actors](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0306-actors.md)
