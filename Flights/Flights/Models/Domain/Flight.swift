import Foundation

/// A flight as the UI understands it: fully parsed, with no JSON or transport concerns.
///
/// Built from `FlightDTO` via a failable mapping, so anything reaching a view is already valid.
nonisolated struct Flight: Identifiable, Hashable, Sendable {
    let id: String
    let tripNumber: String
    /// Genuinely optional — the service returns `null` here for at least one flight.
    let flightNumber: String?
    let tailNumber: String
    let origin: Airport
    let destination: Airport
    let departure: Date
    let arrival: Date
    /// Whole dollars. The service sends an integer and the design renders it as `$349`.
    let price: Decimal

    /// "Las Vegas to New York", as used for list row titles.
    var routeTitle: String {
        "\(origin.city) to \(destination.city)"
    }

    /// "LAS to JFK", as used for the detail screen's large title.
    var routeCode: String {
        "\(origin.iata) to \(destination.iata)"
    }
}
