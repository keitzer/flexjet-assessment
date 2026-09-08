# UI notes and limitations

[Documentation index](README.md) · [Persistence decision](adr/0004-local-persistence.md)

## Settings and typography

Shared font roles live in `Theme.Typography` (`DesignSystem/Theme+Typography.swift`), including
titles, body text, detail fields, captions, buttons, and date chips. SF Symbol font sizes are
separate roles so changing the text family does not change icons. Shared padding and dimensions
use `Theme.Spacing` and `Theme.Size`; skeleton geometry and shimmer parameters stay named within
their components. System text styles retain Dynamic Type scaling.

Profile includes a persisted haptics toggle (on by default) and System / Light / Dark appearance
(System by default). Preferences are device-local in UserDefaults and survive sign-out. Appearance
applies at the app root, including login, with adaptive colors for text, controls and cards.
All app-generated haptics pass through the same preference check; native controls may provide
their own system feedback.

The supplied Figma detail fields use Proxima Nova Bold at 15 px with a 23 px rounded line box.
No Proxima Nova font files are supplied in the repository, so the app still uses the system font.
Detail fields use bold 15-point text, a scaled 23-point minimum row height, and 16-point row gaps.
Exact glyph shapes and text metrics require bundling the actual font files.

## Enhancements

- Initial flight loading uses shimmering card placeholders. Reduce Motion shows static placeholders;
  animation stops when the scene is inactive. VoiceOver exposes a single "Loading flights" element.
  Pull-to-refresh retains the loaded flights instead of replacing them with placeholders.
- The selected Upcoming/Past segment has a contrasting fill and outline in dark mode so selection
  is visible beyond the label's color and weight.

- Keychain-backed session that survives relaunch; 401 signs the user out automatically.
- Loading, empty, and error states with retry; pull-to-refresh.
- A `#Preview` on every component and screen, backed by fixtures and a configurable mock, so each
  one previews offline with no login — including the empty, error and loading states, the null
  flight number, and the 72-character label.
- Accessibility: combined elements with meaningful labels, the segmented control exposed as
  selectable, and completion conveyed by fill and label rather than colour alone.
- Small motion: the segment pill slides via `matchedGeometryEffect`, the completion mark uses a
  symbol replace transition, and completing a flight fires haptic feedback.
  Switching Upcoming/Past starts the selected list at the top; the pill animates independently
  so replacing the rows does not animate their layout or reuse the other category's scroll offset.
- Haptics: heavy impacts at full intensity for sign-in, add flight, flight rows, sign-out, retry,
  sheet dismissal, filter and tab changes, and completing or undoing completion.
  Feedback stays in the UI layer. Check the tactile feel on a physical
  iPhone; simulator tests cannot verify it.
- Strict quality gates: Swift 6, warnings-as-errors, and SwiftLint in strict mode (200-line files,
  40-line functions, no force unwraps) failing the build on any violation.

## Known gaps

- Favorites and Contracts are honest placeholders; the brief does not define them. Profile provides sign-out, haptics settings, and appearance selection.
- The `+` button opens a placeholder — no add-flight flow is specified.
- No UI test target. The view models are covered, but the navigation flow itself is not
  exercised end-to-end.
- Date-dependent rows recompute when the view updates; there is no scheduled refresh at departure
  or midnight yet. A screen left idle can retain its earlier category or Flight Today badge.
