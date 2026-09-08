@testable import Flights
import Testing

@MainActor
@Suite("Flight detail Today badge")
struct FlightDetailBadgeTests {
    @Test("Badge follows local midnight and departure", arguments: [
        ("2026-09-08T03:59:59Z", false),
        ("2026-09-08T04:00:00Z", true),
        ("2026-09-08T07:00:00Z", true),
        ("2026-09-08T07:00:01Z", false)
    ])
    func badgeEligibility(instant: String, expected: Bool) {
        let now = Fixtures.date(instant)
        let flight = Fixtures.flight(departure: "2026-09-08T07:00:00Z", arrival: "2026-09-08T10:00:00Z")
        let classifier = FlightClassifier(calendar: Fixtures.calendar(in: Fixtures.eastern))
        let detail = FlightDetailViewModel(
            flight: flight,
            completion: FlightCompletionStore(storage: InMemoryCompletionStorage()),
            classifier: classifier
        ) { now }

        #expect(detail.showsTodayBadge == expected)
        #expect(detail.showsTodayBadge == classifier.showsTodayBadge(for: flight, now: now))
        if detail.showsTodayBadge {
            #expect(!detail.canToggleCompletion)
        }
    }
}
