@testable import Flights
import Testing

@MainActor
@Suite("Flights scoped to a favorite route")
struct FavoriteRouteFlightsTests {
    @Test("Route lists filter directional codes, partition dates, sort and share completion")
    func matchingFlights() async throws {
        let soon = RouteFixtures.flight(id: "soon", departure: "2026-09-05T15:00:00Z")
        let later = RouteFixtures.flight(id: "later", departure: "2026-09-06T12:00:00Z")
        let past = RouteFixtures.flight(id: "past", departure: "2026-09-04T12:00:00Z")
        let reverse = RouteFixtures.flight(origin: "SEA", destination: "SFO")
        let other = RouteFixtures.flight(destination: "LAX")
        let completion = FlightCompletionStore(storage: InMemoryCompletionStorage())
        let now = Fixtures.date("2026-09-05T12:00:00Z")
        let model = FlightListViewModel(
            apiClient: MockFlightsAPIClient(flightsResult: .success([later, past, reverse, other, soon])),
            session: SessionStore(storage: InMemoryTokenStorage(token: "token")),
            completion: completion,
            routeFilter: RouteIdentity(flight: soon)
        ) { now }
        await model.load()
        #expect(model.items.map(\.id) == ["soon", "later"])
        model.selectedCategory = .past
        #expect(model.items.map(\.id) == ["past"])
        #expect(try #require(model.items.first).model.isComplete == false)
        completion.toggle(past.id)
        #expect(try #require(model.items.first).model.isComplete)
    }

    @Test("A saved route remains available when the service has no matching flights")
    func noMatches() async {
        let route = FavoriteRoute(flight: RouteFixtures.flight())
        let store = FavoriteRoutesStore(storage: InMemoryFavoriteRoutesStorage(routes: [route]))
        let model = FlightListViewModel(
            apiClient: MockFlightsAPIClient(flightsResult: .success([RouteFixtures.flight(destination: "LAX")])),
            session: SessionStore(storage: InMemoryTokenStorage(token: "token")),
            completion: FlightCompletionStore(storage: InMemoryCompletionStorage()),
            routeFilter: route.id
        )
        await model.load()
        #expect(model.state == .loaded)
        #expect(model.isShowingEmptyState)
        model.selectedCategory = .past
        #expect(model.isShowingEmptyState)
        #expect(store.routes == [route])
    }
}
