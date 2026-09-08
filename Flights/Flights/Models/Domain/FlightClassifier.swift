import Foundation

/// Decides which segment a flight belongs to and whether it earns the "Flight Today" badge.
///
/// The clock and calendar are injected rather than read from the environment so the rules can be
/// tested at fixed instants and in arbitrary time zones. `Calendar.autoupdatingCurrent` is the
/// production default, which is what makes the day boundaries follow the user's own time zone.
nonisolated struct FlightClassifier: Sendable {
    private let calendar: Calendar

    init(calendar: Calendar = .autoupdatingCurrent) {
        self.calendar = calendar
    }

    /// A flight is "past" once it has departed; everything else is "upcoming".
    ///
    /// Departure, not arrival, is the boundary: a flight in the air has left and belongs to the
    /// Past list, which matches the design's use of departure dates in both segments.
    func category(for flight: Flight, now: Date) -> FlightCategory {
        hasDeparted(flight, now: now) ? .past : .upcoming
    }

    /// Strictly `departure < now`: a flight leaving at this exact instant has not departed yet.
    func hasDeparted(_ flight: Flight, now: Date) -> Bool {
        flight.departure < now
    }

    /// Whether the departure falls on the current calendar day in the calendar's time zone.
    func departsToday(_ flight: Flight, now: Date) -> Bool {
        calendar.isDate(flight.departure, inSameDayAs: now)
    }

    /// The "Flight Today" badge: upcoming flights only, departing today, not yet departed.
    ///
    /// `hasDeparted` is checked explicitly rather than inferred from the category so the rule
    /// reads the way the spec states it.
    func showsTodayBadge(for flight: Flight, now: Date) -> Bool {
        !hasDeparted(flight, now: now) && departsToday(flight, now: now)
    }

    /// Upcoming flights read soonest-first; past flights read most-recent-first.
    /// Only selects and sorts the requested segment.
    func flights(in category: FlightCategory, from flights: [Flight], now: Date) -> [Flight] {
        flights.filter { self.category(for: $0, now: now) == category }
            .sorted {
                category == .upcoming ? $0.departure < $1.departure : $0.departure > $1.departure
            }
    }
}
