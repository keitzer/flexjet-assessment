@testable import Flights
import Foundation

/// Fixed instants and calendars so tests never depend on the wall clock or the machine's zone.
enum Fixtures {
    static let eastern = TimeZone(identifier: "America/New_York") ?? .gmt
    static let tokyo = TimeZone(identifier: "Asia/Tokyo") ?? .gmt
    static let english = Locale(identifier: "en_US")

    static func calendar(in zone: TimeZone) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone
        calendar.locale = english
        return calendar
    }

    static func formatter(in zone: TimeZone) -> FlightFormatter {
        FlightFormatter(locale: english, calendar: calendar(in: zone), timeZone: zone)
    }

    /// Collapses the Unicode spaces Foundation uses inside formatted output.
    ///
    /// Time styles separate the minutes from AM/PM with a narrow no-break space (U+202F), which
    /// is indistinguishable from a plain space on screen but not in a string comparison.
    /// Normalising keeps the expectations below readable instead of embedding invisible
    /// characters in test literals.
    static func normalized(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\u{202F}", with: " ")
            .replacingOccurrences(of: "\u{00A0}", with: " ")
    }

    /// Parses an ISO-8601 string or fails loudly — test data is always well-formed.
    static func date(_ value: String) -> Date {
        guard let parsed = ISO8601Parsing.date(from: value) else {
            preconditionFailure("Malformed fixture date: \(value)")
        }
        return parsed
    }

    /// Builds a flight with explicit departure/arrival instants.
    static func flight(
        id: String = "FL001",
        departure: String,
        arrival: String,
        flightNumber: String? = "UA890",
        origin: String = "Las Vegas (LAS)",
        destination: String = "New York (JFK)"
    ) -> Flight {
        Flight(
            id: id,
            tripNumber: "1234567",
            flightNumber: flightNumber,
            tailNumber: "N987UA",
            origin: Airport(label: origin, iata: "LAS"),
            destination: Airport(label: destination, iata: "JFK"),
            departure: date(departure),
            arrival: date(arrival),
            price: 349
        )
    }
}
