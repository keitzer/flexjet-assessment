# ADR-0005: Strict linting and a reproducible CLI test lane

Status: Accepted (records the existing implementation).

[Documentation index](../README.md) · [Architecture map](../architecture.md)

## Context

The assessment needs important logic tested and an easy command-line workflow that fails reliably.

## Decision

Use Swift Testing, compiler warnings as errors in Debug and Release, and SwiftLint with defaults
plus explicit opt-ins. Run `swiftlint` directly from the repository root and in the Xcode build
phase. Keep thresholds in [.swiftlint.yml](../../.swiftlint.yml).

Use Bundler-managed Fastlane for the test lane. `.ruby-version` records the tested Ruby patch;
Gemfile declares compatible versions and Gemfile.lock records resolved gems and Bundler. The lane
fails on build, lint, test failures, and zero executed tests. App dependencies remain managed
separately through Swift Package Manager.

The shared Xcode scheme and test lane collect line coverage. `fastlane coverage` runs all tests
and enforces at least 95% in each business layer, while reporting whole-app coverage separately.
Tests mirror production folders; fixtures and service doubles live in `Support`. See
[coverage scope and limitations](../testing.md).

## Consequences

A clean checkout can reproduce the CLI toolchain. Toolchain upgrades are deliberate and verified.
Xcode user script sandboxing is disabled for the Homebrew SwiftLint build phase, which runs without
a lint cache. The lane uses built-in result conversion because xcpretty does not report Swift
Testing cases correctly. Lint catches known patterns; it cannot prove absence of crashes or leaks.
Commands, filters, reports, and coverage live in [development](../development.md).
