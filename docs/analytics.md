# Analytics

[Documentation index](README.md) · [Decision](adr/0007-analytics.md)

## Provider boundary

`Core/Analytics/Analytics.swift` defines the event contract; `AnalyticsLogging` is the replaceable
provider interface. `AppDependencies.live()` creates one wrapper around `ConsoleAnalyticsLogger`
and injects it into stores, view models, routers and the SwiftUI environment. Features never
import a provider SDK. Previews and uninjected unit-test dependencies use a no-op provider.

The current adapter writes structured JSON to local unified logging, using subsystem
`com.interview.Flights` and category `analytics`. Filter for those in Xcode/Console. It sends no
network requests and provides no remote dashboard, durable event queue or delivery guarantee.
Payloads are explicitly public in local logs, so the metadata restrictions below matter.

To integrate a provider, implement `AnalyticsLogging.log(_:)` and replace the logger passed to
`Analytics` in `AppDependencies.live()`. Keep calls short and nonthrowing; an adapter that uploads
must own its queue, batching, retry and delivery policy. The interface is main-actor isolated;
`AnalyticsEvent` and its typed properties are Sendable values for handing off to that queue.

## Event contract

Every event contains `name`, `page`, `timestamp` (UTC ISO-8601 in the console adapter) and
`properties`. Every property dictionary includes integer `schema_version: 1`. Property values
are strings, booleans or integers rather than untyped SDK dictionaries.

| Name | Meaning | Additional properties |
| --- | --- | --- |
| `page_view` | A screen appeared, including returning to it | Optional route/flight context |
| `button_press` | An accepted interaction/action | `action`, optional target context |
| `status_change` | A state owner actually changed a value | `status`, `previous_value`, `value`, optional context |

Pages: `login`, `flights`, `favorites`, `route_details`, `flight_details`, `contracts`, `profile`,
`add_flight`; `app` identifies shell/session events.

Actions include sign-in/out, Add/Done, opening a flight/route, favoriting, completing,
Upcoming/Past selection, tab selection, theme selection, haptics switching, refresh and retry.
Native pickers/toggles/tabs report accepted selection changes; reselecting the current native
value is not a new event. The custom Upcoming/Past buttons record repeated presses, but unchanged
category values do not generate duplicate status events. Disabled sign-in is not an action.

Statuses cover authentication, session signed-in state, loading, category, selected tab, theme,
haptics, Add Flight sheet visibility, navigation depth, route favorite and flight completion.
Authentication/loading failures use stable categories such as `failed_invalid_credentials` or
`failed_offline`, not localized error messages. Restoration does not manufacture a status change.
Refreshing already-loaded data keeps the UI in `loaded`, so it records the refresh action without
inventing a loading transition. Native back buttons and swipe-back report navigation depth changes;
they are not separately distinguished as button presses versus gestures.

Page views are emitted by `.analyticsPage` on appearance, never during body evaluation. They
represent appearances, not unique visitors or sessions. System permission prompts, keyboard keys
and individual rendering/animation updates are outside the app event contract.

## Favorite and completion reporting

Route identity is directional: `origin_iata` and `destination_iata` are normalized airport codes.
Flight context also includes `flight_id` and `flight_number` when available. A favorite action from
flight details has both contexts; an action from route details has only route context.

For example, a completion outcome includes:

```json
{
  "name": "status_change",
  "page": "flight_details",
  "timestamp": "2026-09-08T05:00:00Z",
  "properties": {
    "schema_version": 1,
    "status": "flight_completion",
    "previous_value": false,
    "value": true,
    "flight_id": "FL006",
    "flight_number": "UA890",
    "origin_iata": "LAS",
    "destination_iata": "JFK"
  }
}
```

Uncompleting/unfavoriting reverses the boolean values. These outcome events follow local state
mutation and the storage call; they do not claim a server write or independently verified disk
write. An ineligible upcoming-flight completion produces no completion outcome. The preceding
interaction event is separate, allowing reports to distinguish intent from resulting state.

## Requirements for future features

- Add a stable page identifier and appearance instrumentation for every new screen.
- Instrument meaningful actions at their owner, including their target where applicable.
- Record actual status changes at the state owner; do not infer success from a tap or duplicate
  the same outcome in the view and store. Suppress unchanged values.
- Reuse typed actions/statuses and `AnalyticsContext` factories. Add only necessary reporting
  identifiers; never log passwords, tokens, entered usernames, arbitrary input, raw responses,
  full model dumps or raw errors. Current flight context excludes trip/tail numbers, prices,
  dates and human-readable airport labels.
- Inject the wrapper; do not introduce singletons or direct SDK calls in features.
- Add recording-provider tests for payloads, reversals, rejected/canceled operations and privacy
  boundaries as applicable. Update this catalog and run the business-layer coverage gate.

Unit tests cover the event/serialization contract and business outcomes. Screen appearances and
native control wiring still require a manual log pass; there is no end-to-end UI test target.
