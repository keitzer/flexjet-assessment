@testable import Flights
import Testing

@MainActor
struct CompletionAnalyticsTests {
    @Test("Complete and undo report actual values and flight identity; upcoming actions do not")
    func completionOutcomes() {
        let recorder = RecordingAnalyticsLogger()
        let analytics = Analytics(logger: recorder)
        let flight = RouteFixtures.flight()
        let instant = Fixtures.date("2026-09-08T12:00:00Z")
        let model = FlightDetailViewModel(
            flight: flight,
            completion: FlightCompletionStore(storage: InMemoryCompletionStorage()),
            analytics: analytics
        ) { instant }
        model.toggleCompletion()
        model.toggleCompletion()
        #expect(recorder.events.count == 2)
        #expect(recorder.events.map { $0.properties["value"] } == [.bool(true), .bool(false)])
        #expect(recorder.events.map { $0.properties["previous_value"] } == [.bool(false), .bool(true)])
        #expect(recorder.events.allSatisfy {
            $0.properties["status"] == .string("flight_completion")
                && $0.properties["flight_id"] == .string(flight.id) && $0.page == .flightDetails
        })
        let upcoming = FlightDetailViewModel(
            flight: RouteFixtures.flight(departure: "2026-09-09T12:00:00Z"),
            completion: FlightCompletionStore(storage: InMemoryCompletionStorage()),
            analytics: analytics
        ) { instant }
        upcoming.toggleCompletion()
        #expect(recorder.events.count == 2)
    }
}
