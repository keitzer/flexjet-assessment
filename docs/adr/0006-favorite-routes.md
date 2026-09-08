# ADR-0006: Directional favorite routes

Status: Accepted.

[Documentation index](../README.md) · [Architecture map](../architecture.md)

## Context

Multiple flights can serve the same route. Users want to save that route once, browse its upcoming
and past flights, and open normal flight details. The service has no favorites or route endpoint.
Its airport display labels can disagree with the separately supplied IATA codes.

## Decision

Identify a route by the ordered pair of origin and destination IATA codes, normalized for case and
surrounding whitespace. SFO → SEA and SEA → SFO are different routes. Flight IDs, dates and display
labels do not affect matching. Store the endpoint labels alongside the identity so a saved route
remains useful when the latest service response has no matching flights.

A shared observable `FavoriteRoutesStore` persists favorites as versioned JSON in UserDefaults.
The dependency container supplies one instance to both tabs and their detail screens. Like existing
completion preferences for this single-user assessment, favorites survive logout and are local to
the device. Invalid stored JSON loads as an empty collection; duplicate identities are deduplicated.

Only flight details and route details expose favorite/unfavorite actions, as a navigation-bar heart. The Favorites list is
navigation-only. Removing a favorite updates that list immediately, while an already-open detail
page remains usable and can favorite the route again.

Route details reuse `FlightListViewModel` with an immutable route filter and `FlightResultsView`.
They reuse a shared in-memory flights snapshot for the current session, fetching the documented
flights endpoint only when no cache exists or on explicit refresh/retry. They filter locally, retaining the existing loading,
error/retry, cancellation, session-expiry, date classification, sorting, completion and time-refresh
behaviour. Each tab has its own typed navigation stack; destination construction is shared.

## Consequences

Saving any flight on a route affects every flight with that directional identity. Reverse routes
remain independent. Saved labels are snapshots from the flight used to favorite the route; we do
not rewrite or infer airport labels from contradictory service data. A route with no matching
upcoming/past flights shows an empty state rather than disappearing from Favorites.

The cache includes successful empty responses and is scoped to the session revision rather than
the token string. Signing out and back in cannot reuse the previous session's flights. Older
requests cannot overwrite a newer refresh's cached snapshot. It is not persisted to disk and has
no automatic expiry; pull-to-refresh requests fresh service data. Already-loaded screens retain
their own snapshot, while subsequent route visits use the latest successful cached response.
Classification and formatting use the current clock and time zone, not the time of the fetch.
See [testing and coverage](../testing.md) for matching, persistence and navigation checks.
