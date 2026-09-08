# Architecture map

[Documentation index](README.md)

MVVM with a typed router, and a hard line between business logic and the UI layer.

```
App/          entry point, DI container, tab shell, navigation router
Core/
  Networking/ FlightsAPIClient protocol, live URLSession client, mock, APIError
  Session/    SessionStore, Keychain + in-memory TokenStorage
  Completion/ FlightCompletionStore and its persistence
Models/
  DTO/        wire types + failable mapping to domain
  Domain/     Flight, Airport, FlightClassifier, sample fixtures
  Formatting/ FlightFormatter
DesignSystem/ tokens + reusable components
Features/     Login, FlightList, FlightDetail, Placeholders
```

## Decisions

- [ADR-0001: MVVM, typed navigation, and dependency injection](adr/0001-swiftui-architecture.md)
- [ADR-0002: Service client and domain validation](adr/0002-service-and-domain.md)
- [ADR-0003: Concurrency and request lifecycle](adr/0003-concurrency.md)
- [ADR-0004: Local persistence](adr/0004-local-persistence.md)
- [ADR-0005: Quality tooling](adr/0005-quality-tooling.md)
