# Architecture map

[Documentation index](README.md)

MVVM with a typed router, and a hard line between business logic and the UI layer.

```
App/          entry point, DI container, tab shell, navigation router
Core/
  Flights/    session-scoped in-memory flights cache
  Networking/ FlightsAPIClient protocol, live URLSession client, mock, APIError
  Session/    SessionStore, Keychain + in-memory TokenStorage
  Completion/ FlightCompletionStore and its persistence
  Favorites/  FavoriteRoutesStore and local route persistence
Models/
  DTO/        wire types + failable mapping to domain
  Domain/     Flight, Airport, FlightClassifier, route identity, sample fixtures
  Formatting/ FlightFormatter
DesignSystem/ tokens + reusable components
Features/     Login, FlightList, FlightDetail, Favorites, Placeholders
```

## Decisions

- [ADR-0001: MVVM, typed navigation, and dependency injection](adr/0001-swiftui-architecture.md)
- [ADR-0002: Service client and domain validation](adr/0002-service-and-domain.md)
- [ADR-0003: Concurrency and request lifecycle](adr/0003-concurrency.md)
- [ADR-0004: Local persistence](adr/0004-local-persistence.md)
- [ADR-0005: Quality tooling](adr/0005-quality-tooling.md)
- [ADR-0006: Favorite routes](adr/0006-favorite-routes.md)

Analytics uses an injected provider boundary, shared typed events and state-owned outcomes.
See the [event catalog](analytics.md) and [ADR 0007](adr/0007-analytics.md).
