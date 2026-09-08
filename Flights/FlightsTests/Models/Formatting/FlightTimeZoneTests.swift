@testable import Flights
import Foundation
import Testing

@Suite("Time-zone and daylight-saving boundaries")
struct FlightTimeZoneTests {
    @Test("Eastern clock skips the missing hour at spring-forward")
    func springForward() {
        let formatter = Fixtures.formatter(in: Fixtures.eastern)
        let before = Fixtures.date("2026-03-08T06:59:00Z")
        let after = Fixtures.date("2026-03-08T07:00:00Z")
        #expect(Fixtures.normalized(formatter.timeRange(from: before, to: after)) == "1:59 AM - 3:00 AM")
    }

    @Test("Repeated fall-back clock times remain distinct departure instants")
    func fallBack() {
        let first = Fixtures.date("2026-11-01T05:30:00Z")
        let second = Fixtures.date("2026-11-01T06:30:00Z")
        let formatter = Fixtures.formatter(in: Fixtures.eastern)
        #expect(Fixtures.normalized(formatter.time(for: first)) == "1:30 AM")
        #expect(formatter.time(for: first) == formatter.time(for: second))
        let flight = Fixtures.flight(departure: "2026-11-01T06:30:00Z", arrival: "2026-11-01T08:00:00Z")
        let classifier = FlightClassifier(calendar: Fixtures.calendar(in: Fixtures.eastern))
        #expect(classifier.category(for: flight, now: first) == .upcoming)
        #expect(classifier.showsTodayBadge(for: flight, now: first))
        #expect(classifier.category(for: flight, now: second.addingTimeInterval(1)) == .past)
    }

    @Test("Fractional-hour offsets are preserved")
    func fractionalOffset() throws {
        let zone = try #require(TimeZone(identifier: "Asia/Kathmandu"))
        let formatter = Fixtures.formatter(in: zone)
        #expect(Fixtures.normalized(formatter.time(for: Fixtures.date("2026-09-05T12:00:00Z"))) == "5:45 PM")
    }

    @Test("Row dates, badges, times and details agree across the international date boundary", arguments: [
        "America/Los_Angeles", "Pacific/Kiritimati"
    ])
    func dateBoundary(zoneName: String) throws {
        let zone = try #require(TimeZone(identifier: zoneName))
        let formatter = Fixtures.formatter(in: zone)
        let classifier = FlightClassifier(calendar: Fixtures.calendar(in: zone))
        let flight = Fixtures.flight(departure: "2027-01-01T00:30:00Z", arrival: "2027-01-01T03:00:00Z")
        let now = Fixtures.date("2026-12-31T09:00:00Z")
        let row = FlightRowModelBuilder(formatter: formatter, classifier: classifier)
            .make(from: flight, isComplete: false, now: now)
        let detail = FlightDetailPresenter(formatter: formatter).make(from: flight, now: now)
        let isPacific = zoneName == "America/Los_Angeles"
        #expect(row.month == (isPacific ? "DEC" : "JAN"))
        #expect(row.day == (isPacific ? "31" : "01"))
        #expect(row.showsTodayBadge == isPacific)
        #expect(!row.isPast)
        #expect(Fixtures.normalized(row.subtitle) == (isPacific ? "4:30 PM - 7:00 PM" : "2:30 PM - 5:00 PM"))
        #expect(detail.fields.first?.value.hasPrefix(isPacific ? "Dec 31" : "Jan 1") == true)
    }

    @Test("An explicit display zone also controls relative-date calendar boundaries")
    func coherentCalendar() {
        let mismatched = FlightFormatter(
            locale: Fixtures.english,
            calendar: Fixtures.calendar(in: Fixtures.eastern),
            timeZone: Fixtures.tokyo
        )
        let expected = Fixtures.formatter(in: Fixtures.tokyo)
        let date = Fixtures.date("2026-09-06T16:00:00Z")
        let now = Fixtures.date("2026-09-05T14:00:00Z")
        let actual = mismatched.departureDescription(for: date, now: now)
        #expect(actual == expected.departureDescription(for: date, now: now))
    }
}
