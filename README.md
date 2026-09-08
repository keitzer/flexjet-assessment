# Flights

iOS interview app built with SwiftUI and Swift 6. App dependencies use Swift Package Manager.

## Setup

Install the SwiftLint developer tool:

```sh
brew install swiftlint
```

Validated with SwiftLint 0.65.1. Homebrew installs its current version; review rule changes when upgrading.

Open `Flights/Flights.xcodeproj` in Xcode.

## Code quality

Run lint from the repository root:

```sh
swiftlint
```

The Flights target also runs SwiftLint before compilation on every build. Missing SwiftLint or any
lint violation fails the build. Debug and Release use Swift 6 and treat Swift compiler warnings as errors.

`.swiftlint.yml` retains SwiftLint's default rules and adds stricter checks for unsafe unwraps,
SwiftUI state visibility, collection usage, formatting, and redundant code. Limits are 120 characters
per line (URLs exempt), 40 lines per function, 250 lines per type, 400 lines per file, five function
parameters, and cyclomatic complexity of 10. All warning thresholds are enforced as errors.

Prefer extracting small views and functions to suppressing rules. Any necessary suppression should
target a specific rule and the smallest scope, with a comment explaining why it is needed.

Xcode user script sandboxing is disabled on the app target so the Homebrew SwiftLint executable can
read the repository and load the Swift toolchain. The build phase disables lint caching.
