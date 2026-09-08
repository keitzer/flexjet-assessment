# ADR-0001: SwiftUI, MVVM, and typed navigation

Status: Accepted (records the existing implementation).

[Documentation index](../README.md) · [Architecture map](../architecture.md)

## Context

The app needs testable presentation logic and navigation across a small set of SwiftUI screens.

## Decision

Use SwiftUI and Observation with MVVM. `FlightsRouter` owns a typed `[FlightRoute]` path; screens
request navigation through the router. `AppDependencies` is created once in `FlightsApp` and
passed into view models and the SwiftUI environment. Previews substitute mock services.

## Consequences

Business rules stay outside views, and presentation state can be tested without rendering UI.
Navigation has a central owner without a UIKit view-controller coordinator. Dependencies remain
explicit; system-backed UI preferences are documented separately in [ADR-0004](0004-local-persistence.md).
