# Working on Flights

## Collaboration

- Respect the user's current scope and any hold on implementation work.
- Other sessions may be editing this checkout. Preserve existing changes, inspect relevant files
  before editing, and avoid unrelated refactors or overwriting another session's work.
- Keep these instructions focused on durable decisions. Record implementation decisions and actual
  time spent in README.md; do not invent time estimates presented as time already spent.

## Stack and architecture

- Use SwiftUI and Swift 6. App dependencies are managed with Swift Package Manager.
- MVVM with coordinator-owned navigation is the preferred direction. Follow the established layers
  as they evolve; do not introduce a competing architecture or abstractions without a concrete need.
- Keep networking, data validation, and business rules separate from SwiftUI views. View models
  expose presentation state and coordinate actions; views render state and forward user intent.
- Prefer Observation for observable presentation state and async/await for asynchronous requests.
  Combine and third-party packages are options when justified, not requirements.
- A small URLSession-backed API client behind a protocol is sufficient for the documented service.
- Keep API DTOs separate from domain and presentation concerns. Make mapping and validation explicit.
  Failable mapping is acceptable, but define how invalid records are surfaced or handled.
- Inject dependencies so tests can replace services and time inputs. Environment injection is welcome;
  business logic should remain usable without a SwiftUI environment.
- Respect Swift 6 actor isolation and Sendable requirements. Do not silence concurrency diagnostics
  with unchecked annotations merely to make a build pass.

## Behavior to preserve

- Authenticate through the service, handle rejected credentials, and send the returned bearer token
  with flight requests. Do not implement authentication as a local credential comparison.
- Populate flights from service data. Display flight times in the user's current time zone.
- Show Flight Today only for upcoming flights whose departure is today in the user's time zone
  and is still in the future. Make the exact departure boundary explicit and test it.
- Keep upcoming/past classification separate from the user's completion flag unless the product
  requirements explicitly change that behavior.
- Completing a flight in its details must update the corresponding list checkmark.
- The supplied service documentation has no completion endpoint. Document the chosen local state
  and persistence behavior rather than assuming the service supports completion updates.

## Quality and validation

- Run `swiftlint` from the repository root. `.swiftlint.yml` is the source of truth for lint rules
  and limits; strict mode treats warnings as errors. Xcode also runs lint during builds.
- Preserve Swift 6 language mode and Swift compiler warnings as errors in Debug and Release.
- Prefer smaller, focused implementations to lint suppressions. Any necessary suppression should
  name a specific rule, use the smallest scope, and explain the reason.
- When implementing or changing important logic, add focused unit tests using the project's chosen
  test framework. Prioritize DTO mapping, authentication and request failures, flight classification,
  Flight Today eligibility, completion propagation, and presentation state transitions.
- Make date tests deterministic with controlled time, calendar, and time zone inputs. Cover midnight,
  the departure instant, and time zone differences; include daylight-saving transitions where relevant.
- Use service doubles for unit tests rather than the live API. Cover loading, empty, success, and
  failure states where applicable, and cancellation behavior when the implementation supports it.
- Run checks appropriate to the change and report what actually passed, failed, or was not run.
  Do not change app code or run competing builds during an explicit hold from the user.
