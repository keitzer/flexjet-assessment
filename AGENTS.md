# Working on Flights

## Collaboration

- Respect the user's current scope and any hold on implementation work.
- Other sessions may be editing this checkout. Preserve existing changes, inspect relevant files
  before editing, and avoid unrelated refactors or overwriting another session's work.
- Keep these instructions focused on durable decisions. Record actual time spent in README.md;
  put detailed implementation notes in docs/ and architectural decisions
  in docs/adr/. Keep README.md brief. Do not invent time estimates presented as time already spent.

## Stack and architecture

- Use SwiftUI and Swift 6. App dependencies are managed with Swift Package Manager.
- MVVM with coordinator-owned navigation is the preferred direction. Follow the established layers
  as they evolve; do not introduce a competing architecture or abstractions without a concrete need.
  This is now implemented as a typed router, not a UIKit-style coordinator: `FlightsRouter` is an
  `@Observable` owning a `[FlightRoute]` path of plain values. Screens call `router.showDetail(_:)`
  rather than building their own destinations. Do not reintroduce view-controller-style coordinators.
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
- `@MainActor` serializes access but does not make an async operation atomic. Validate session
  revision and request identity after suspension before applying results or errors.
- SwiftUI `.task` manages lifecycle cancellation; plain `Task {}` does not. Store handles for
  button-launched tasks and cancel them when the owning view disappears. Cancellation is cooperative:
  check before publishing results and in processing loops, and preserve `CancellationError`.
- Keep view initializers cheap and free of network calls. Initializing an injected observable model
  in `@State` is acceptable here because its initializer only assigns dependencies and initial state.
- Under the project's Swift 6.2 settings, `nonisolated async` can inherit the caller's actor.
  Use `@concurrent` deliberately for work that must leave that actor; neither `Task {}` nor an
  arbitrary actor guarantees a dedicated background thread. `@preconcurrency` is a migration escape
  hatch, not evidence that a dependency is thread-safe.

## Behavior to preserve

- Authenticate through the service, handle rejected credentials, and send the returned bearer token
  with flight requests. Do not implement authentication as a local credential comparison.
- Populate flights from service data. Display flight times in the user's current time zone.
- Show Flight Today only for upcoming flights whose departure is today in the user's time zone
  and has not passed. The established boundary is `departure < now` for past flights; the exact
  departure instant remains upcoming. Keep this boundary explicit and tested.
- Keep upcoming/past classification separate from the user's completion flag unless the product
  requirements explicitly change that behavior.
- Completing a flight in its details must update the corresponding list checkmark.
- The supplied service documentation has no completion endpoint. Document the chosen local state
  and persistence behavior rather than assuming the service supports completion updates.

## Analytics for every feature

- Instrument new screens with `.analyticsPage`, meaningful interactions with `Analytics.button`,
  and actual status changes with `Analytics.change`. Record outcomes at the state owner, not by
  assuming a tap succeeded. Avoid duplicate events and unchanged-value status events.
- Inject the existing wrapper; vendor adapters belong behind `AnalyticsLogging`, never in features.
  Use stable typed identifiers and allowlisted route/flight context. Never log credentials, tokens,
  entered usernames, raw API payloads, raw errors or full domain models.
- Add recording-logger tests for important event payloads and outcomes; update `docs/analytics.md`.
  See `docs/adr/0007-analytics.md` for the provider boundary and delivery limitations.

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
- Keep test folders aligned with production folders and shared doubles in `FlightsTests/Support`.
  Run `bundle exec fastlane coverage` for business-logic changes; it enforces 95% per layer.
  Keep coverage scope current as new layers are introduced (see `docs/testing.md`).
- Run checks appropriate to the change and report what actually passed, failed, or was not run.
  Do not change app code or run competing builds during an explicit hold from the user.


## Decisions already made

Recorded so a later session extends them instead of relitigating them. The reasoning lives in
docs/adr/ (indexed by docs/README.md); this is the short form.

- Navigation is a typed router (above), not a coordinator object.
- Isolation follows the layer. The target sets `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, so
  domain models, formatting and networking are explicitly `nonisolated` and only UI-facing state
  (`SessionStore`, `FlightCompletionStore`, view models) is main-actor isolated. Mark new value
  types crossing actors `nonisolated`; do not reach for `@unchecked Sendable` to silence this.
  The remaining production `@unchecked` conformance is `UserDefaultsCompletionStorage`, because
  `UserDefaults` predates `Sendable` but is documented thread-safe. In-memory storage and the
  test request recorder use `Synchronization.Mutex` with compiler-checked Sendable conformance.
- Invalid flight records are dropped, not surfaced as an error: `Flight.init?(dto:)` is the single
  domain validation point. `FlightsResponseDTO` isolates per-record decoding failures, including
  wrong field types. Malformed top-level JSON still fails the request.
- Completion is device-local (`UserDefaults`) because the service has no write endpoint. The auth
  token is a credential and lives in the Keychain instead.
- A 401 on an authenticated route ends the session, returning the user to login.
- Only the latest flight request for the current session revision may publish results or expire
  the session, even if a later login receives an identical token.
  Cancellation is not a user-facing service failure; preserve loaded data or allow an initial retry.
- No third-party app dependencies. Two endpoints do not justify a networking library.
  Fastlane is a developer tool managed separately through Bundler and Gemfile.lock.
  `.ruby-version` records the tested local Ruby; `Gemfile.lock` records the Bundler version under
  `BUNDLED WITH`. Update those deliberately alongside any toolchain upgrade and verify the test lane.
- Guard preview blocks that use debug-only mocks or helpers with `#if DEBUG` too; `#Preview`
  references are still type-checked in Release. Verify a Release build after preview changes.
- Contracts and the `+` button remain honest placeholders. Favorites is implemented for directional
  routes keyed by normalized origin/destination IATA codes. Only flight/route details expose the
  favorite action as a navigation-bar heart; lists are navigation-only. Favorites persist locally
  and share one store across tabs. Flight lists prefer the shared session-scoped in-memory cache;
  explicit refresh/retry fetches from the API. See `docs/adr/0006-favorite-routes.md`.

## Service quirks

Verified against the live API, not assumed. Re-check before changing decoding or formatting.

Root: `https://v0-simple-authentication-api.vercel.app` — sole user `john` / `12345`.

| Quirk | Consequence |
| --- | --- |
| `flightNumber` is nullable (`FL006`) | Past rows fall back to the tail number; detail shows an em dash |
| `FL034` has a 72-char origin label ending `(JFK)` but `originIata: SFO` | Label and IATA are kept independent; never derive one from the other. Long labels wrap, not truncate |
| Live sends `...:00.000Z`; the published docs show plain `...:00Z` | `ISO8601Parsing` accepts both layouts |
| `price` is an integer in **dollars**, no currency field | Rendered `$349`; USD assumed |
| JWT expires after 24h | Expiry is handled reactively via 401, not by decoding `exp` |
| No completion endpoint exists | Completion is local-only; do not invent a PATCH |

## Traps that cost real time

- UIKit dynamic-color provider closures can execute on SwiftUI's background renderer. Create them
  in a `nonisolated` context (see `Color.init(light:dark:)`), otherwise default MainActor isolation
  can cause a dispatch queue assertion during animated color changes. `ThemeColorTests` resolves
  the adaptive color off the main actor; keep this regression check.

- `Date.AnchoredRelativeFormatStyle` describes the **anchor relative to the value**, which is the
  opposite of how it reads. Format `now` with the flight's date as the anchor to get "2w ago"
  rather than "in 2w". `FlightFormatterTests` pins both directions.
- iOS separates the time from AM/PM with a narrow no-break space (**U+202F**), not a space. Two
  identical-looking strings compare unequal. Tests compare via `Fixtures.normalized(_:)`.
- SwiftLint `strict: true` promotes every warning to an error, so the *warning* thresholds are the
  real limits: **200 lines per file**, 40 per function, 120 columns, 3-char minimum identifiers,
  no force unwrapping, imports sorted with `@testable` first. Plan for many small files.
- Leading-dot shorthand does not resolve on an existential parameter: write
  `MockFlightsAPIClient.empty`, not `.empty`, where the parameter is `any FlightsAPIClient`.
- iOS 26 places `.toolbar` items in a floating capsule above a large title. The Flights header is
  drawn in content instead, so the title and `+` share one row as the design shows.
- xcpretty cannot populate JUnit reports for Swift Testing. The test lane sets
  `xcodebuild_formatter: ""` so `run_tests` uses its built-in trainer conversion of `.xcresult`
  instead. Keep `fail_build: true`, fail when no tests run, and verify passing and failing paths
  after touching the lane. Avoid overlapping runs in the same build/report directories.
- Never assert with `#expect` inside `URLProtocol.startLoading()` or any other callback off the
  test's task context. Swift Testing attributes those to `Test «unknown»` and `xcodebuild test`
  still exits **0**, so the check cannot fail CI. `StubURLProtocol` captures each request instead
  and the tests assert on it from the test body, where a failure exits 65.
- Simulator Keychain items **survive `simctl uninstall`**, so an app reinstall can still launch
  signed in and a "fresh install" is not actually fresh. To get back to the login screen use
  `xcrun simctl keychain <device> reset` (uninstalling or wiping `UserDefaults` will not do it).
  This is simulator behaviour, not an app bug — session restore is intended.

## Commands

```sh
swiftlint                                   # from the repository root
bundle exec fastlane test                    # all unit tests; bundle install on first setup
bundle exec fastlane test only:"FlightsTests/FlightClassifierTests"
xcodebuild -project Flights/Flights.xcodeproj -scheme Flights \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

The `Flights` shared scheme includes the `FlightsTests` target, so `Cmd-U` works on a fresh clone.

Debug builds accept `-seedToken <jwt>` to launch already signed in, for inspecting the signed-in
screens without typing on the simulator keyboard. It compiles out of Release. Obtain a token with:

```sh
curl -s -X POST "$ROOT/api/signIn" -H "Content-Type: application/json" \
  -d '{"username":"john","password":"12345"}'
```
