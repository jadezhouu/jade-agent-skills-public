# Cancellation, bridging, and verification

Use only the mechanisms relevant to the task; do not add stream libraries or testing dependencies for simple async calls.

## Task groups and blocking

- Ordinary `withTaskGroup` / `withThrowingTaskGroup` scopes await all children on normal exit rather than automatically cancelling them; a throwing exit from the group body cancels and awaits them. When racing for a first result or ending early, call `cancelAll()` as appropriate, but the group still awaits every child; a child that ignores cancellation can prevent a “timeout” from returning promptly.
- Observe and propagate throwing-group child errors through `next()`, iteration, or equivalent; do not assume any child error immediately terminates the entire group. Bound in-flight batch work according to resource limits rather than unconditionally creating every task at once.
- Do not use semaphores or synchronous waits on a cooperative executor to depend on another task's completion. Synchronous locks can protect short critical sections, but must not span `await`; use appropriate dedicated execution resources for genuinely blocking legacy APIs, not `Task.detached` as a dedicated blocking thread.

## Callbacks and event streams

- Prefer an existing async API for a single callback, otherwise bridge with a checked continuation; success, failure, and cancellation paths must collectively resume it exactly once. Checked continuations detect misuse but do not supply missing callbacks or cancellation.
- Cancellation handling can race with registration and completion, and the operation can still start after cancellation. Use a synchronized state machine for cancellation-before-registration and completion-versus-cancellation races; define responsibility for cancelling underlying work and resuming the continuation to avoid missing or duplicate resumes.
- Consider `AsyncStream` for repeated events. Define buffer limits, dropping policy, termination, and producer cleanup; `yield` does not wait for consumers, and bounded buffering is not backpressure. Do not treat a stream or channel as automatic broadcast; design distribution semantics separately for multiple subscribers.
- Unregister observer/delegate resources on termination and handle races between registration and termination; a consumer's `break` is not proof that the producer has stopped. Introduce AsyncAlgorithms only when its operators are needed, without forcing replacement of an existing correct debounce implementation.

## Verification focus

- Use controlled dependencies, clocks, or explicit handshakes to exercise out-of-order results and cancellation/completion races; a single `Task.yield()` or fixed sleep does not prove another task reached a given state. Keep the existing test framework; do not require globally serial execution or a scheduler library.
- As relevant to the change, cover cancellation before start and during execution, late stale results, repeated/missing callbacks, stream termination, and owner release. Select only relevant paths and assert external behavior rather than implementation details.

## Verified sources

Checked against official proposals on 2026-10-16; historical examples in proposals are not templates for current SDK code.

- [SE-0304: Structured concurrency and cancellation](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0304-structured-concurrency.md)
- [SE-0300: Continuation contract](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0300-continuation.md)
- [SE-0314: AsyncStream buffering and termination](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0314-async-stream.md)
