import Foundation

/// The formatted contents of the flight detail screen.
nonisolated struct FlightDetailModel: Hashable, Sendable {
    /// "LAS to JFK"
    let title: String
    /// "Las Vegas (LAS)"
    let originLabel: String
    /// "New York (JFK)"
    let destinationLabel: String
    let fields: [Field]

    nonisolated struct Field: Hashable, Identifiable, Sendable {
        let label: String
        let value: String

        var id: String { label }
    }
}

/// Builds `FlightDetailModel`s. Pure and injectable so the field list and its formatting are
/// unit-testable without instantiating a view.
nonisolated struct FlightDetailPresenter: Sendable {
    private let formatter: FlightFormatter

    init(formatter: FlightFormatter = FlightFormatter()) {
        self.formatter = formatter
    }

    /// Placeholder for a field the service left null.
    static let missingValue = "—"

    func make(from flight: Flight, now: Date) -> FlightDetailModel {
        FlightDetailModel(
            title: flight.routeCode,
            originLabel: flight.origin.label,
            destinationLabel: flight.destination.label,
            fields: [
                .init(
                    label: "Departure Date",
                    value: formatter.departureDescription(for: flight.departure, now: now)
                ),
                .init(label: "Trip Number", value: flight.tripNumber),
                .init(label: "Flight Number", value: flight.flightNumber ?? Self.missingValue),
                .init(label: "Tail Number", value: flight.tailNumber),
                .init(label: "Price", value: formatter.price(flight.price))
            ]
        )
    }
}
