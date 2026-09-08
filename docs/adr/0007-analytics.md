# ADR 0007: Provider-independent, structured analytics

- Status: Accepted
- Date: 2026-09-08

## Context

Page views, interactions and meaningful state changes need consistent reporting, including route
favorites and flight completion. No analytics vendor has been selected, and instrumentation should
remain testable without network traffic or coupling business logic to SwiftUI or a vendor SDK.

## Decision

Inject an `Analytics` wrapper backed by the `AnalyticsLogging` protocol. Compose a local unified-log
adapter in `AppDependencies.live()`; previews use a no-op and tests a recording implementation.
Use typed pages, actions, statuses and metadata values with a versioned event envelope.

Views own appearance/interaction events. View models, stores and the router own outcome events;
settings views own their AppStorage transitions. Separate intent from actual changes and suppress
unchanged values. Include directional IATA route identity and selected flight identifiers for
reporting, with explicit metadata factories rather than serializing domain models or credentials.

## Consequences

A vendor integration replaces one adapter without changing feature call sites. Analytics does not
block or control app behavior. Future delivery, batching, consent and retention policies belong to
that integration and require deliberate decisions; none is simulated by the local logger.

Every future feature must include relevant analytics and payload tests. Main-actor logging calls
must return promptly; event values are Sendable for asynchronous provider work. Local logs have no
durability or remote reporting guarantee. Native back gestures/buttons are represented by navigation
state transitions. See the [event catalog and implementation requirements](../analytics.md).
