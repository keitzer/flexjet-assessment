@testable import Flights
import Testing

@MainActor
struct FlightListAnalyticsTests {
    @Test("Loading and category selection distinguish presses from actual state changes")
    func listEvents() async {
        let recorder = RecordingAnalyticsLogger()
        let route = RouteIdentity(flight: RouteFixtures.flight())
        let model = FlightListViewModel(
            apiClient: MockFlightsAPIClient.empty,
            session: SessionStore(storage: InMemoryTokenStorage(token: "private-token")),
            completion: FlightCompletionStore(storage: InMemoryCompletionStorage()),
            routeFilter: route,
            analytics: Analytics(logger: recorder)
        )
        await model.loadIfNeeded()
        await model.loadIfNeeded()
        #expect(recorder.events.map { $0.properties["value"] } == [.string("loading"), .string("loaded")])
        model.recordCategoryPress(.past)
        model.selectedCategory = .past
        model.recordCategoryPress(.past)
        model.selectedCategory = .past
        #expect(recorder.events.map(\.name) == [
            "status_change", "status_change", "button_press", "status_change", "button_press"
        ])
        #expect(recorder.events.allSatisfy {
            $0.page == .routeDetails && $0.properties["origin_iata"] == .string("SFO")
        })
    }
}
