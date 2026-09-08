import Foundation

/// Refresh at the next day/departure boundary, with a minute ceiling for relative text.
nonisolated enum FlightRefreshSchedule {
    static let relativeTextInterval: TimeInterval = 60
    // Departure is a strict boundary, so wake just after it rather than exactly on it.
    static let departureDelay: TimeInterval = 0.001

    static func nextRefresh(
        after now: Date,
        departures: [Date],
        calendar: Calendar = .autoupdatingCurrent
    ) -> Date {
        let ceiling = now.addingTimeInterval(relativeTextInterval)
        let midnight = calendar.dateInterval(of: .day, for: now)?.end ?? ceiling
        let departure = departures
            .map { $0.addingTimeInterval(departureDelay) }
            .filter { $0 > now }
            .min() ?? ceiling
        return min(ceiling, midnight, departure)
    }
}
