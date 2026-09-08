@testable import Flights
import Testing

@MainActor
struct FavoriteAnalyticsTests {
    @Test("Favorite and unfavorite retain directional identity and their source page")
    func favoriteOutcomes() {
        let recorder = RecordingAnalyticsLogger()
        let flight = RouteFixtures.flight()
        let route = FavoriteRoute(flight: flight)
        let storage = InMemoryFavoriteRoutesStorage()
        let store = FavoriteRoutesStore(storage: storage, analytics: Analytics(logger: recorder))
        #expect(recorder.events.isEmpty)
        store.toggle(route, source: .flightDetails, context: .flight(flight))
        store.toggle(route)
        #expect(recorder.events.map(\.page) == [.flightDetails, .routeDetails])
        #expect(recorder.events.map { $0.properties["value"] } == [.bool(true), .bool(false)])
        #expect(recorder.events.allSatisfy {
            $0.properties["origin_iata"] == .string("SFO")
                && $0.properties["destination_iata"] == .string("SEA")
                && $0.properties["status"] == .string("route_favorite")
        })
        #expect(recorder.events[0].properties["flight_id"] == .string(flight.id))
        #expect(recorder.events[1].properties["flight_id"] == nil)
        #expect(storage.load().isEmpty)
    }
}
