# ADR-0003: Actor isolation and request lifecycle protection

Status: Accepted (records the existing implementation).

[Documentation index](../README.md) · [Architecture map](../architecture.md)

## Context

Swift 6 checks data-race safety, but actor reentrancy still permits stale async responses after
refreshes, cancellation, or session changes.

## Decision

Use MainActor for UI-facing observable state. The target defaults to MainActor isolation; domain,
formatting, and networking value types are explicitly nonisolated and Sendable. Live API methods
use `@concurrent` to move decoding off the caller actor under Swift 6.2. Validate request identity
and session revision after suspension before publishing state or expiring a session.

Use SwiftUI `.task` for initial loading. Retain button-launched task handles and cancel them when
the owning view disappears. Preserve cancellation and check it before publishing results and
during record processing. In-memory shared stores use `Synchronization.Mutex`.

## Consequences

An old response cannot replace newer data or sign out a newer session, even if tokens repeat.
Cancellation remains cooperative; MainActor alone is not an atomicity guarantee. Lifecycle and
cancellation regression tests are described in [development](../development.md#test-coverage).
