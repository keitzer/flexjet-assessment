# Service and flight behavior

[Documentation index](README.md) · [Data boundary decision](adr/0002-service-and-domain.md)

## Service

Root: `https://v0-simple-authentication-api.vercel.app`

- `POST /api/signIn` with `username` and `password` returns a bearer token.
- `GET /api/flights` requires `Authorization: Bearer <token>`.
- Public demo credentials: `john` / `12345`.

## Observed data quirks

Working against the live service turned up several things worth calling out.

- **`flightNumber` is nullable.** `FL006` returns `null`. Past rows show the flight
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

## Classification and formatting

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

## Completion

The service exposes no write endpoint, so completion is device-local: `FlightCompletionStore`
persists a set of flight IDs to `UserDefaults` (a non-sensitive preference, unlike the auth token,
which lives in the Keychain). The store is shared through the environment and the list's rows are
computed rather than stored, so marking a flight complete on the detail screen updates the row's
checkmark on the way back — driven by shared state, not by passing a callback up the stack.
Completion and undo are available only after departure, using the same strict `departure < now`
boundary as the Past list. Upcoming details hide the button, and the view model also guards the action.

See [ADR-0004](adr/0004-local-persistence.md) for persistence decisions.

## Favorite routes

Favorites use directional origin/destination IATA pairs and persist in UserDefaults. Only flight
and route details expose save/remove controls. The Favorites tab lists saved routes, including
routes with no matching flights in the latest response. Route details filter `GET /api/flights`
locally, preferring the shared session cache; explicit refresh/retry fetches fresh data. Normal
Upcoming/Past rules, date formatting and completion state are reused. No write
endpoint is assumed. See [ADR-0006](adr/0006-favorite-routes.md).
