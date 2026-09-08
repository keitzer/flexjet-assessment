# Flights

An iOS take-home for Flexjet: sign in against a flights service, browse Upcoming and Past
flights, and mark past flights complete.

SwiftUI, Swift 6 with strict concurrency, `@Observable`, no third-party app dependencies.

## Running

Open `Flights/Flights.xcodeproj` and run the **Flights** scheme (iOS 26 simulator).

Sign in with the service's sole user: **`john` / `12345`**.

Tests: `Cmd-U`, or use the Fastlane test lane from the repository root. The toolchain is recorded in
`.ruby-version` (Ruby 3.3.12) and `Gemfile.lock` (Bundler 2.6.9 and Fastlane 2.239.0).
The Gemfile requires Ruby 3.3.x; `.ruby-version` selects the exact tested patch version with rbenv.

One-time setup with rbenv:

```sh
rbenv install -s
gem install bundler -v 2.6.9
bundle config set --local path vendor/bundle
bundle install
```

Run all unit tests:

```sh
bundle exec fastlane test
```

The lane defaults to the iPhone 17 Pro simulator and Debug configuration. It builds the app,
runs `FlightsTests`, and exits unsuccessfully on build, lint, or test failures, or if no tests
match the filter. SwiftLint runs
through the existing Xcode build phase. No Apple account setup is needed for this lane.

Optional simulator and test filters:

```sh
bundle exec fastlane test device:"iPhone 17"
bundle exec fastlane test only:"FlightsTests/FlightClassifierTests"
bundle exec fastlane test only:"FlightsTests/FlightClassifierTests/badgeForLaterToday()"
```

List available simulators with `xcrun simctl list devices available`. Results, including JUnit
and an Xcode `.xcresult` bundle, are saved under `fastlane/test_output/`; build products go in
`build/DerivedData/`. Both locations are ignored by Git. Commit `Gemfile` and `Gemfile.lock`
so everyone installs the same Fastlane dependencies. The Gemfile currently permits Fastlane 2.239.x
patch updates through `bundle update fastlane`; change its constraint for a later minor release.

For a single Swift Testing function, include its parentheses in the quoted identifier as above.

The underlying Xcode command remains available:

```sh
xcodebuild -project Flights/Flights.xcodeproj -scheme Flights \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

SwiftLint is required (`brew install swiftlint`) and runs as a build phase; any violation fails
the build. See "Code quality" below.

## Architecture

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

**Why these choices**

- **MVVM over a full Coordinator.** A UIKit-style coordinator that builds and presents view
  controllers fights SwiftUI. The same separation is expressed by `FlightsRouter`: an
  `@Observable` object owning a `[FlightRoute]` path, where `FlightRoute` is a plain value.
  Screens call `router.showDetail(flight)` instead of constructing their own destinations, so
  routing lives in one place and is drivable from a test or a deep link.
- **DTOs separate from domain models.** `FlightDTO` mirrors the JSON with optional fields;
  `Flight.init?(dto:)` decides what a usable flight is. `FlightsResponseDTO` decodes records
  individually, so missing fields, wrong field types, and non-object entries are dropped without
  discarding valid siblings. Invalid JSON or a non-array response still produces a decoding error.
- **Plain URLSession behind a protocol.** Two endpoints do not justify a networking dependency.
  Views depend on `FlightsAPIClient`, never on `URLSession`, so previews and tests substitute
  `MockFlightsAPIClient` with no network.
- **Isolation follows the layer.** The target builds with `SWIFT_DEFAULT_ACTOR_ISOLATION =
  MainActor`. Domain models, formatting and networking are explicitly `nonisolated` (they are
  values that cross actors); only UI-facing state — `SessionStore`, `FlightCompletionStore`, the
  view models — is main-actor isolated.
- **Environment injection.** `AppDependencies` is built once in `FlightsApp` and passed down; no
  type reaches for a singleton. `.preview()` swaps in stubs.

## Notes on the data

Working against the live service turned up several things worth calling out.

- **`flightNumber` is genuinely nullable.** `FL006` returns `null`. Past rows show the flight
  number, so that row falls back to the **tail number** rather than rendering a blank line.
  The detail screen shows an em dash.
- **`FL034` contradicts itself**: a 72-character origin label ending in `(JFK)` alongside an
  `originIata` of `SFO`. The two fields are kept independent — each screen uses the one the
  design calls for — and the long label is allowed to wrap rather than being truncated.
- **Two timestamp formats.** The live feed sends fractional seconds (`...:00.000Z`); the
  published docs show the same field without them. `ISO8601Parsing` accepts both, so a change in
  the service's serialiser cannot break decoding.
- **Price is dollars, not cents.** The docs render `349` as `$349`. No currency field is sent, so
  USD is assumed.
- **The token expires after 24h.** A 401 on an authenticated route ends the session, which
  returns the app to login rather than showing an error the user cannot act on.

## Business rules

Isolated in `FlightClassifier` and `FlightFormatter`, both with injected clock, calendar, locale
and time zone so they can be tested at fixed instants in arbitrary zones.

- **Upcoming vs Past** splits on *departure*, not arrival: a flight in the air has left. The
  boundary is strict (`departure < now`), so a flight leaving this exact second is still upcoming.
- **Flight Today** requires all three: upcoming, departing today, not yet departed. "Today" is
  evaluated in the user's calendar, which is what makes the badge follow the device's time zone.
- **Ordering**: upcoming soonest-first, past most-recent-first, matching the design.
- **Time zone**: the service sends UTC; every displayed date and time is rendered through
  `.autoupdatingCurrent`, so the same instant reads 8:00 AM in New York and 9:00 PM in Tokyo.
  `FlightFormatterTests` pins exactly that case.

One subtlety worth flagging: `Date.AnchoredRelativeFormatStyle` describes the *anchor* relative to
the value being formatted, which is the opposite of how it reads. Formatting `now` with the
flight's date as the anchor is what yields "2w ago" rather than "in 2w"; the tests pin both
directions so it cannot silently regress.

## Completion state

The service exposes no write endpoint, so completion is device-local: `FlightCompletionStore`
persists a set of flight IDs to `UserDefaults` (a non-sensitive preference, unlike the auth token,
which lives in the Keychain). The store is shared through the environment and the list's rows are
computed rather than stored, so marking a flight complete on the detail screen updates the row's
checkmark on the way back — driven by shared state, not by passing a callback up the stack.

## Testing

77 tests in 17 suites, written with Swift Testing (87 executions including parameterized cases).
They cover the logic that would actually break:

- `FlightClassifierTests` — segment split, the Flight Today rule, the departure boundary, per-zone
  day boundaries, and ordering within each segment.
- `FlightFormatterTests` / `ISO8601ParsingTests` — chip and range formatting, both timestamp
  layouts, relative dates in both directions, and the same instant across two time zones.
- `FlightMappingTests` — decoding a verbatim live record, the null flight number, and that one
  malformed record is dropped without discarding the valid ones.
- `FlightRowModelBuilderTests` / `FlightDetailPresenterTests` — what each row and field says.
- `FlightListViewModelTests` — loaded, empty and failed states, and that a 401 ends the session.
- `LoginViewModelTests`, `FlightCompletionStoreTests`, `SessionStoreTests`.
- `LiveFlightsAPIClientTests` — request paths, methods, JSON credentials, bearer headers, nullable
  fields, malformed records, HTTP failures, blank tokens, and transport cancellation. A stateless
  `URLProtocol` stub intercepts requests; these tests never contact the live service.
- `FlightRequestLifecycleTests` — only the latest request can publish results; old responses cannot
  sign out a newer session; cancelling an initial load leaves it retryable; cancelling a refresh
  preserves loaded data.
- `LoginRegressionTests` — clearing a rejected password retains the error until the user edits,
  and cancelled sign-in preserves the form without authenticating.
- `CompletionPropagationTests` — toggling details updates an already-loaded list and persisted
  completion state without another fetch.
- `SignInLifecycleTests` — late successes and failures after cancellation or session changes,
  sign-out during authentication, and duplicate submissions.
- `FlightDecodingCancellationTests` — cancelled record processing exits with cancellation.

UI-facing observable state remains on `MainActor`. Session revisions protect against stale responses
even when two sessions use the same token. Login and retry tasks retain cancellation handles that
their views cancel on disappearance; initial loading uses SwiftUI's `.task`. The live API methods
use `@concurrent` to keep response decoding off the caller's actor under Swift 6.2's isolation rules.
In-memory stores use `Synchronization.Mutex`, avoiding unchecked Sendable conformance.

Formatted output is compared through a helper that normalises Unicode spaces: iOS separates the
minutes from AM/PM with U+202F, which is invisible on screen but not in a string comparison.

## Nice-to-haves included

- Keychain-backed session that survives relaunch; 401 signs the user out automatically.
- Loading, empty, and error states with retry; pull-to-refresh.
- A `#Preview` on every component and screen, backed by fixtures and a configurable mock, so each
  one previews offline with no login — including the empty, error and loading states, the null
  flight number, and the 72-character label.
- Accessibility: combined elements with meaningful labels, the segmented control exposed as
  selectable, and completion conveyed by fill and label rather than colour alone.
- Small motion: the segment pill slides via `matchedGeometryEffect`, the completion mark uses a
  symbol replace transition, and completing a flight fires haptic feedback.
- Strict quality gates: Swift 6, warnings-as-errors, and SwiftLint in strict mode (200-line files,
  40-line functions, no force unwraps) failing the build on any violation.

**Debug affordance:** in Debug builds only, launching with `-seedToken <jwt>` starts the app
already signed in. It exists so the signed-in screens can be inspected without typing credentials
on a simulator keyboard, and it compiles out of Release.

## Known gaps

- Favorites and Contracts are honest placeholders; the brief does not define them. Profile is
  real to the extent that it owns sign-out.
- The `+` button opens a placeholder — no add-flight flow is specified.
- No UI test target. The view models are covered, but the navigation flow itself is not
  exercised end-to-end.
- Date-dependent rows recompute when the view updates; there is no scheduled refresh at departure
  or midnight yet. A screen left idle can retain its earlier category or Flight Today badge.

## Time breakdown

| Area | Time |
| --- | --- |
| First Pass | 0.5 Hours |
| Nice-to-haves (tests, previews, states, a11y) | 1 hours |
| Additional (project setup, lint config, README) | 1.5 hours |

## Code quality

Run lint from the repository root:

```sh
swiftlint
```

Validated with SwiftLint 0.65.1. The Flights target also runs SwiftLint before compilation on
every build; a missing SwiftLint or any violation fails the build. Debug and Release use Swift 6
and treat Swift compiler warnings as errors.

`.swiftlint.yml` keeps SwiftLint's default rules and adds stricter checks for unsafe unwraps,
SwiftUI state visibility, collection usage, formatting, and redundant code. Limits are 120
characters per line (URLs exempt), 40 lines per function, 250 lines per type, 200 lines per file,
five function parameters, and cyclomatic complexity of 10. All warning thresholds are enforced as
errors.

Prefer extracting small views and functions to suppressing rules. Any necessary suppression should
target a specific rule and the smallest scope, with a comment explaining why it is needed.

Xcode user script sandboxing is disabled on the app target so the Homebrew SwiftLint executable
can read the repository and load the Swift toolchain. The build phase disables lint caching.
