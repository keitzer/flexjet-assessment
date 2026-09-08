# Documentation

[Project overview and quick start](../README.md)

| Reference | Contents |
| --- | --- |
| [Architecture](architecture.md) | Source layout and decision links |
| [Development](development.md) | Setup, CLI filters, reports, tests, lint, debug launch |
| [Service and behavior](service-and-behavior.md) | API quirks, validation, dates, time zones, completion |
| [UI notes](ui-notes.md) | Settings, typography, enhancements, known gaps |

## Architecture decision records

ADRs record context, the accepted decision, and its consequences. Keep operational instructions
in the reference docs above; add a numbered ADR when a significant decision changes, linking any
superseded record.

| ADR | Decision | Status |
| --- | --- | --- |
| [0001](adr/0001-swiftui-architecture.md) | SwiftUI, MVVM, typed navigation, dependency injection | Accepted |
| [0002](adr/0002-service-and-domain.md) | Protocol-based networking and separate DTOs | Accepted |
| [0003](adr/0003-concurrency.md) | Actor isolation and request lifecycle protection | Accepted |
| [0004](adr/0004-local-persistence.md) | Keychain sessions and device-local preferences | Accepted |
| [0005](adr/0005-quality-tooling.md) | Strict linting and a reproducible CLI test lane | Accepted |
