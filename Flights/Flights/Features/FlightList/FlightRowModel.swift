import Foundation

/// Everything a flight row draws, already formatted.
///
/// The row view renders these strings verbatim, so the decisions about what a row says live in
/// `FlightRowModelBuilder` where they can be tested without a view.
nonisolated struct FlightRowModel: Identifiable, Hashable, Sendable {
    let id: String
    let month: String
    let day: String
    /// "Las Vegas to New York"
    let title: String
    /// Time range for upcoming flights, flight identifier for past ones.
    let subtitle: String
    let showsTodayBadge: Bool
    /// Past rows carry the completion checkmark; upcoming rows do not.
    let showsCompletion: Bool
    let isComplete: Bool
    let isPast: Bool
}

/// Builds `FlightRowModel`s. Pure and injectable, so every rule below is unit-testable.
nonisolated struct FlightRowModelBuilder: Sendable {
    private let formatter: FlightFormatter
    private let classifier: FlightClassifier

    init(formatter: FlightFormatter = FlightFormatter(), classifier: FlightClassifier = FlightClassifier()) {
        self.formatter = formatter
        self.classifier = classifier
    }

    func make(from flight: Flight, isComplete: Bool, now: Date) -> FlightRowModel {
        let isPast = classifier.hasDeparted(flight, now: now)
        return FlightRowModel(
            id: flight.id,
            month: formatter.monthAbbreviation(for: flight.departure),
            day: formatter.dayOfMonth(for: flight.departure),
            title: flight.routeTitle,
            subtitle: subtitle(for: flight, isPast: isPast),
            showsTodayBadge: classifier.showsTodayBadge(for: flight, now: now),
            showsCompletion: isPast,
            isComplete: isComplete,
            isPast: isPast
        )
    }

    /// Upcoming rows show the times; past rows show the flight identifier, per the design.
    ///
    /// The service returns a null `flightNumber` for at least one flight, so the tail number is
    /// used as the fallback — it still identifies the aircraft rather than showing a blank line.
    private func subtitle(for flight: Flight, isPast: Bool) -> String {
        guard isPast else {
            return formatter.timeRange(from: flight.departure, to: flight.arrival)
        }
        return flight.flightNumber ?? flight.tailNumber
    }
}

/// Pairs a row's display model with the flight it was built from, so tapping a row can route to
/// that flight without a lookup.
nonisolated struct FlightListItem: Identifiable, Hashable, Sendable {
    let flight: Flight
    let model: FlightRowModel

    var id: String { flight.id }
}
