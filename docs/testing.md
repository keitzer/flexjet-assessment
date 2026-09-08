# Testing and coverage

[Documentation index](README.md) · [Development commands](development.md)

## Run and inspect

```sh
bundle exec fastlane coverage
```

This runs the entire unit-test target, writes `fastlane/test_output/coverage.json`, and fails
if any of the four business layers below has less than **95% line coverage**. Build, lint, test
failures and zero executed tests also fail the run. An optional `device:"iPhone 17"` selects
another installed simulator. Coverage deliberately does not accept a test filter: a partial
suite cannot establish the full baseline.

`bundle exec fastlane test` also collects coverage and still supports `only:` filters. The shared
Xcode scheme enables coverage for Cmd-U. Inspect individual files/functions in Xcode's test report
or from the repository root:

```sh
xcrun xccov view --report fastlane/test_output/Flights.xcresult
```

Reports and build products stay ignored by Git. The coverage lane prints whole-app coverage
separately; that includes views, previews, placeholders, and startup code. Startup can exercise
different UI branches depending on simulator session state, so use the business-layer results
for the stable logic baseline.

## Scope of the gate

| Layer | Included code |
| --- | --- |
| Domain, DTOs and formatting | All `Models/` files except `Flight+Samples.swift` |
| Networking, session and persistence | All `Core/` files except `MockFlightsAPIClient.swift` |
| Feature view models and presenters | `Features/` files ending in `Model.swift`, including `ViewModel.swift` |
| Navigation | All `App/Navigation/` files |

Each percentage is covered executable lines divided by total executable lines in that layer,
not an average of per-file percentages. A missing app target or empty layer fails the command.
Add new logic to these established layers or update the gate's scope when the architecture changes.
The gate applies when running `coverage`; merely running `test` or Cmd-U does not enforce it.

## Measured baseline (2026-09-08)

The full suite passed **155 executions** (including parameterized cases), with **677/683 covered
business-logic lines (99.12%)**:

| Layer | Covered / executable | Line coverage |
| --- | --- | --- |
| Domain, DTOs and formatting | 174 / 175 | 99.43% |
| Networking, session and persistence | 263 / 267 | 98.50% |
| Feature view models and presenters | 226 / 227 | 99.56% |
| Navigation | 14 / 14 | 100% |

Re-run the lane for current results. These numbers include infrastructure fallback code and do not
exclude uncovered production methods within the measured layers.

## Finding the matching tests

`Flights/FlightsTests/` mirrors the production folders:

- `App/Navigation/`: typed navigation state.
- `Core/Networking/`, `Core/Session/`, `Core/Completion/`, `Core/Favorites/`, `Core/Flights/`: transport, persistence and cache.
- `Models/Domain/`, `Models/DTO/`, `Models/Formatting/`: rules, mapping and presentation values.
- `Features/Login/`, `Features/FlightList/`, `Features/FlightDetail/`, `Features/Favorites/`: feature behaviour.
- `DesignSystem/`: preferences and background color-resolution regressions.
- `Support/`: fixtures, controllable clocks, service doubles, and the URLProtocol request recorder.

Existing suite names remain unchanged, so CLI `only:` filters continue to work. Suites previously
embedded in unrelated files (session/completion in login tests, detail presentation in row tests,
and ISO parsing in formatter tests) now have their own files.

## Time-zone and clock guarantees

UTC timestamps are parsed into absolute `Date` values. Formatting and calendar-day classification
use the user's autoupdating zone in production; tests inject explicit zones, calendars and clocks.
An explicit formatter zone also overrides its calendar's zone, keeping relative dates consistent
with displayed dates and clock times.

Focused assertions cover:

- Local midnight, including the days surrounding both daylight-saving transitions.
- Spring-forward's skipped hour and fall-back's repeated hour, preserving absolute departure order.
- Fractional-hour offsets and year/day changes across the international date boundary.
- Agreement between row date chips, times, Today badges and detail departure dates.
- The strict departure boundary: exactly at departure remains upcoming; immediately afterwards is past.
- An already-loaded list and detail transitioning at midnight/departure without fetching again.

Both screens use a shared lifecycle modifier. It refreshes on appearance/foregrounding, system
clock/time-zone/locale changes, local midnight, and just after departure. A one-minute ceiling
keeps relative text current. The cancellable sleep stops when the scene becomes inactive or the
view disappears; timing policy is a pure `FlightRefreshSchedule` tested separately from SwiftUI.
There is no real-time scheduling guarantee: a busy app updates when its main actor next runs.
The system notification handling follows Apple's
[significant time change documentation](https://developer.apple.com/documentation/uikit/uiapplication/significanttimechangenotification),
which includes midnight, carrier clock updates and daylight-saving changes.

## Favorite-route checks

Tests cover directional IATA matching independent of flight IDs/labels, code normalization,
reverse-route isolation, deduplication, deterministic ordering, local persistence, removal,
corrupt-data recovery, filtered Upcoming/Past sorting, completion propagation, empty route results,
and route-to-flight back-stack navigation. Cache tests count API calls across route visits,
empty results and explicit refresh, reject cross-session reuse and stale writes, and verify
classification uses the current clock. Favorites reuse the tested request lifecycle and
calendar rules rather than implementing separate networking or date logic.

## Interpreting coverage

High line coverage is an execution measure, not proof of every branch or correct behaviour.
Tests therefore assert outcomes for malformed API records (including each missing required field),
rejected credentials, expired sessions, stale concurrent responses, cancellation, completion
propagation and persistence. Keychain tests use unique service names and remove their own test keys;
UserDefaults tests use isolated suites. Network tests use doubles and never require the live API.

The remaining uncovered logic includes defensive fallbacks and a default clock closure. We do
not weaken those guards or manufacture unreachable conditions just to claim 100% coverage.

There is no end-to-end UI test target. Hosted completion rendering is tested, but actual OS delivery
of time-zone/clock notifications, navigation gestures, keyboard layout, VoiceOver and haptics still
need manual checks. For time-zone QA, leave a list/detail open, change the device zone in Settings,
return to the app, and confirm that dates/times and Today eligibility update consistently.
