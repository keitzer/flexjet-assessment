import Foundation

/// An endpoint of a flight.
///
/// The service sends the location twice: a human label such as `"Las Vegas (LAS)"` and a
/// separate `originIata` / `destinationIata` code. Those two can disagree — `FL034` ships a
/// label ending in `(JFK)` alongside an IATA code of `SFO` — so the two stay independent here
/// and each screen uses the field the design calls for rather than deriving one from the other.
nonisolated struct Airport: Hashable, Sendable {
    /// The label exactly as sent, e.g. `"Las Vegas (LAS)"`. Shown on the detail screen.
    let label: String
    /// The label with any trailing parenthesised code removed, e.g. `"Las Vegas"`.
    /// Used to build list titles like "Las Vegas to New York".
    let city: String
    /// The airport code as sent, e.g. `"LAS"`. Used for the detail screen's title.
    let iata: String

    init(label: String, iata: String) {
        self.label = label
        self.city = Self.strippingTrailingCode(from: label)
        self.iata = iata
    }

    /// Removes a trailing `" (CODE)"` from a location label.
    ///
    /// Only a parenthesised group at the very end is removed, and only when it is the label's
    /// *last* component, so a name that legitimately contains brackets earlier in the string
    /// survives intact. Labels without a trailing group are returned unchanged.
    static func strippingTrailingCode(from label: String) -> String {
        let trimmed = label.trimmingCharacters(in: .whitespaces)
        guard trimmed.hasSuffix(")"), let openIndex = trimmed.lastIndex(of: "(") else {
            return trimmed
        }
        let city = trimmed[trimmed.startIndex..<openIndex]
        let stripped = city.trimmingCharacters(in: .whitespaces)
        // Guard against a label that is nothing but a code, e.g. "(LAS)".
        return stripped.isEmpty ? trimmed : stripped
    }
}
