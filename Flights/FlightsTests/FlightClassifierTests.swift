@testable import Flights
import Foundation
import Testing

@Suite("Flight classification and the Flight Today badge")
struct FlightClassifierTests {
    private let classifier = FlightClassifier(calendar: Fixtures.calendar(in: Fixtures.eastern))
    /// 2026-09-05 08:00 Eastern.
    private let now = Fixtures.date("2026-09-05T12:00:00Z")

    @Test("A flight that has not departed is upcoming")
    func upcomingBeforeDeparture() {
        let flight = Fixtures.flight(departure: "2026-09-05T15:00:00Z", arrival: "2026-09-05T18:00:00Z")
        #expect(classifier.category(for: flight, now: now) == .upcoming)
    }

    @Test("A flight is past the moment it departs, even while still in the air")
    func pastOnceDeparted() {
        let flight = Fixtures.flight(departure: "2026-09-05T11:00:00Z", arrival: "2026-09-05T23:00:00Z")
        #expect(classifier.category(for: flight, now: now) == .past)
        #expect(classifier.hasDeparted(flight, now: now))
    }

    @Test("The badge shows for an upcoming flight departing later today")
    func badgeForLaterToday() {
        let flight = Fixtures.flight(departure: "2026-09-05T22:00:00Z", arrival: "2026-09-06T02:00:00Z")
        #expect(classifier.showsTodayBadge(for: flight, now: now))
    }

    @Test("The badge is hidden once the flight has departed, even on the same day")
    func noBadgeAfterDeparture() {
        let flight = Fixtures.flight(departure: "2026-09-05T11:00:00Z", arrival: "2026-09-05T14:00:00Z")
        #expect(classifier.departsToday(flight, now: now))
        #expect(!classifier.showsTodayBadge(for: flight, now: now))
    }

    @Test("The badge is hidden for a flight on a later day")
    func noBadgeForFutureDay() {
        let flight = Fixtures.flight(departure: "2026-09-06T15:00:00Z", arrival: "2026-09-06T18:00:00Z")
        #expect(!classifier.showsTodayBadge(for: flight, now: now))
    }

    @Test("Today is decided in the user's time zone, not UTC")
    func todayFollowsUserTimeZone() {
        // 2026-09-06 01:00 UTC is still 2026-09-05 in New York but already the 6th in Tokyo.
        let flight = Fixtures.flight(departure: "2026-09-06T01:00:00Z", arrival: "2026-09-06T04:00:00Z")
        let eastern = FlightClassifier(calendar: Fixtures.calendar(in: Fixtures.eastern))
        let tokyo = FlightClassifier(calendar: Fixtures.calendar(in: Fixtures.tokyo))
        #expect(eastern.showsTodayBadge(for: flight, now: now))
        #expect(!tokyo.showsTodayBadge(for: flight, now: now))
    }

    @Test("Upcoming sorts soonest first and past sorts most recent first")
    func partitionOrdersEachSegment() {
        let soon = Fixtures.flight(id: "soon", departure: "2026-09-05T15:00:00Z", arrival: "2026-09-05T18:00:00Z")
        let later = Fixtures.flight(id: "later", departure: "2026-09-08T15:00:00Z", arrival: "2026-09-08T18:00:00Z")
        let recent = Fixtures.flight(id: "recent", departure: "2026-09-04T15:00:00Z", arrival: "2026-09-04T18:00:00Z")
        let oldest = Fixtures.flight(id: "oldest", departure: "2026-09-01T15:00:00Z", arrival: "2026-09-01T18:00:00Z")

        let result = classifier.partition([later, oldest, soon, recent], now: now)

        #expect(result[.upcoming]?.map(\.id) == ["soon", "later"])
        #expect(result[.past]?.map(\.id) == ["recent", "oldest"])
    }

    @Test("A flight departing at exactly this instant has not departed yet")
    func departureBoundaryIsExclusive() {
        // The boundary is strict: a flight is past only once its departure is behind us, so a
        // flight leaving at this exact second still counts as upcoming.
        let flight = Fixtures.flight(departure: "2026-09-05T12:00:00Z", arrival: "2026-09-05T15:00:00Z")
        #expect(classifier.category(for: flight, now: now) == .upcoming)
        #expect(!classifier.hasDeparted(flight, now: now))
    }
}
