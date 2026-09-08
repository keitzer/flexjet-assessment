@testable import Flights
import Foundation
import Testing

@Suite("Flight formatting")
struct FlightFormatterTests {
    private let formatter = Fixtures.formatter(in: Fixtures.eastern)
    /// 2026-09-05 08:00 Eastern / 21:00 Tokyo.
    private let departure = Fixtures.date("2026-09-05T12:00:00.000Z")
    private let arrival = Fixtures.date("2026-09-05T18:00:00Z")

    @Test("Date chip shows an uppercase month and a two-digit day")
    func formatsDateChip() {
        #expect(formatter.monthAbbreviation(for: departure) == "SEP")
        #expect(formatter.dayOfMonth(for: departure) == "05")
    }

    @Test("Times render in the user's time zone")
    func formatsTimeRange() {
        #expect(Fixtures.normalized(formatter.timeRange(from: departure, to: arrival)) == "8:00 AM - 2:00 PM")
    }

    @Test("The same instant renders differently in another time zone")
    func adaptsToTimeZone() {
        let tokyo = Fixtures.formatter(in: Fixtures.tokyo)
        #expect(Fixtures.normalized(tokyo.time(for: departure)) == "9:00 PM")
        // Late enough in UTC that Tokyo has already rolled over to the next day.
        let lateNight = Fixtures.date("2026-09-05T16:00:00Z")
        #expect(formatter.dayOfMonth(for: lateNight) == "05")
        #expect(tokyo.dayOfMonth(for: lateNight) == "06")
    }

    @Test("Price renders as whole dollars")
    func formatsPrice() {
        #expect(formatter.price(349) == "$349")
        #expect(formatter.price(12500) == "$12,500")
    }

    @Test("A past departure reads as elapsed, not upcoming")
    func formatsPastRelativeDate() {
        let now = Fixtures.date("2026-09-19T12:00:00Z")
        #expect(formatter.relativeDescription(for: departure, now: now) == "2w ago")
        #expect(formatter.departureDescription(for: departure, now: now) == "Sep 5 (2w ago)")
    }

    @Test("A future departure reads as upcoming")
    func formatsFutureRelativeDate() {
        let now = Fixtures.date("2026-09-02T12:00:00Z")
        #expect(formatter.relativeDescription(for: departure, now: now) == "in 3d")
    }

    @Test("Short date drops the year, matching the design")
    func formatsShortDate() {
        #expect(formatter.shortDate(for: departure) == "Sep 5")
    }
}

@Suite("ISO-8601 parsing")
struct ISO8601ParsingTests {
    @Test("Accepts the fractional-second form the live service sends")
    func parsesFractionalSeconds() {
        let parsed = ISO8601Parsing.date(from: "2026-09-05T12:00:00.000Z")
        #expect(parsed == Date(timeIntervalSince1970: 1_788_609_600))
    }

    @Test("Accepts the plain form shown in the API documentation")
    func parsesWholeSeconds() {
        let parsed = ISO8601Parsing.date(from: "2026-09-05T12:00:00Z")
        #expect(parsed == Date(timeIntervalSince1970: 1_788_609_600))
    }

    @Test("Rejects a value that is not a timestamp", arguments: ["", "tomorrow", "2026-13-45T99:99:99Z"])
    func rejectsMalformedValues(value: String) {
        #expect(ISO8601Parsing.date(from: value) == nil)
    }
}
