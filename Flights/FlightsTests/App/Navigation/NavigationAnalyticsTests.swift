@testable import Flights
import Testing

@MainActor
struct NavigationAnalyticsTests {
    @Test("Push and native path removal report destination context and depth")
    func navigationTransitions() {
        let recorder = RecordingAnalyticsLogger()
        let router = FlightsRouter(analytics: Analytics(logger: recorder), rootPage: .favorites)
        let flight = RouteFixtures.flight()
        router.showRoute(FavoriteRoute(flight: flight))
        router.showDetail(flight)
        router.path.removeLast()
        router.popToRoot()
        router.popToRoot()
        #expect(recorder.events.map(\.page) == [.routeDetails, .flightDetails, .routeDetails, .favorites])
        #expect(recorder.events.map { $0.properties["value"] } == [
            .integer(1), .integer(2), .integer(1), .integer(0)
        ])
        #expect(recorder.events[1].properties["flight_id"] == .string(flight.id))
        #expect(recorder.events[3].properties["origin_iata"] == nil)
    }
}
