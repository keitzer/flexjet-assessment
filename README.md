# Flights

An iOS take-home for Flexjet: sign in, browse Upcoming/Past flights in your time zone, and mark
past flights complete. Includes persistent sessions, retry/refresh states, haptics, and appearance settings.

## Architecture

SwiftUI + Swift 6 + Observation, using MVVM with a typed navigation router and injected dependencies.
A URLSession client sits behind a protocol; DTO validation, business rules, and formatting stay
outside views. Tokens use Keychain; completion and preferences are device-local. No third-party
app dependencies. [Architecture and ADRs](docs/architecture.md)

## Get started

Requires Xcode with the iOS 26.2+ SDK and simulator runtime, plus SwiftLint (`brew install swiftlint`).
Open `Flights/Flights.xcodeproj`, select **Flights**, and run. Demo login: **`john` / `12345`**.

Run tests in Xcode with **Cmd-U**, or set up the CLI tools with rbenv installed:

```sh
rbenv install -s
gem install bundler -v 2.6.9
bundle config set --local path vendor/bundle
bundle install
bundle exec fastlane test
swiftlint
```

Ruby and gem versions are recorded in `.ruby-version` and `Gemfile.lock`. The test lane defaults
to an iPhone 17 Pro simulator. Lint violations and compiler warnings fail the build.
[More commands and test coverage](docs/development.md)

## Scope notes

Favorites, Contracts, and Add Flight are placeholders. Completion is local-only. There is no UI
test target, idle date-based screens do not refresh on a timer, and Proxima Nova assets are pending.
[UI notes and limitations](docs/ui-notes.md) · [Service behavior](docs/service-and-behavior.md)

## Time breakdown

| Area | Recorded time |
| --- | --- |
| First pass (Login + Flights; not tracked separately) | 0.5 hours |
| Nice-to-haves (tests, previews, states, accessibility) | 1+ hours |
| Additional (project setup, lint config, README) | 1.5 hours |

These are the previously recorded figures; subsequent iterations have not been added.

[Full documentation and decision index](docs/README.md)
