# Development and testing

[Documentation index](README.md) · [Tooling decision](adr/0005-quality-tooling.md)

## Setup and commands

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
the build. See [Code quality](#code-quality) below.

## Test coverage

Tests use Swift Testing with deterministic fixtures and service doubles. The test lane reports
the current execution count, including parameterized cases. Coverage includes:

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
- `AppPreferencesTests` — haptics defaults and persistence, and appearance mapping.
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

SwiftLint keeps its default rules plus explicit opt-ins in `.swiftlint.yml`. Strict mode makes
every violation fail the command and the Xcode build. Safety checks include forced casts/tries/
unwraps, weak delegates, unowned captures, discarded throwing tasks, and discarded notification
observer tokens. Style checks also enforce trailing closures and access modifiers on individual
extension members. Nesting is limited to one nested type level and two nested function levels;
cyclomatic complexity starts failing at the configured warning threshold of 10.

Rule names and behavior were checked with SwiftLint 0.65.1. `fatal_error_nil_coalescing` and
`anyobject_protocol` are not available rules in that version. `fatal_error_message` requires a
diagnostic message; it does not prohibit fatal errors. The Swift compiler's warnings-as-errors
setting rejects the deprecated `protocol Example: class` syntax in favor of `AnyObject`.
Lint reduces known risks but does not prove absence of retain cycles, crashes, or concurrency bugs.

## Debug launch

In Debug builds only, launching with `-seedToken <jwt>` starts the app
already signed in. It exists so the signed-in screens can be inspected without typing credentials
on a simulator keyboard, and it compiles out of Release.
