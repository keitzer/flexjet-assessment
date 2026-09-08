@testable import Flights
import Foundation
import Testing

@MainActor
@Suite("Route details reuse the session's flights")
struct FavoriteRouteCacheTests {
    private func model(
        client: FlightsAPIClient,
        session: SessionStore,
        cache: FlightsCache,
        route: RouteIdentity? = nil,
        now: Date = Fixtures.date("2026-09-05T12:00:00Z")
    ) -> FlightListViewModel {
        FlightListViewModel(
            apiClient: client,
            session: session,
            completion: FlightCompletionStore(storage: InMemoryCompletionStorage()),
            routeFilter: route,
            cache: cache
        ) { now }
    }

    @Test("Opening a route uses the Flights tab's snapshot without a second API call")
    func cachedRoute() async {
        let flight = RouteFixtures.flight()
        let client = CountingFlightsAPIClient(result: .success([flight, RouteFixtures.flight(destination: "LAX")]))
        let session = SessionStore(storage: InMemoryTokenStorage(token: "token"))
        let cache = FlightsCache()
        await model(client: client, session: session, cache: cache).loadIfNeeded()
        let route = model(client: client, session: session, cache: cache, route: RouteIdentity(flight: flight))
        await route.loadIfNeeded()
        #expect(await client.requestCount == 1)
        #expect(route.items.map(\.id) == [flight.id])
        #expect(route.state == .loaded)
    }

    @Test("A successful empty response is cached too")
    func emptyCache() async {
        let client = CountingFlightsAPIClient(result: .success([]))
        let session = SessionStore(storage: InMemoryTokenStorage(token: "token"))
        let cache = FlightsCache()
        await model(client: client, session: session, cache: cache).loadIfNeeded()
        let next = model(client: client, session: session, cache: cache)
        await next.loadIfNeeded()
        #expect(next.isShowingEmptyState)
        #expect(await client.requestCount == 1)
    }

    @Test("Explicit refresh fetches and replaces the cache for subsequent route visits")
    func explicitRefresh() async {
        let client = CountingFlightsAPIClient(result: .success([]))
        let session = SessionStore(storage: InMemoryTokenStorage(token: "token"))
        let cache = FlightsCache()
        let first = model(client: client, session: session, cache: cache)
        await first.loadIfNeeded()
        let flight = RouteFixtures.flight()
        await client.setResult(.success([flight]))
        await first.load()
        let next = model(client: client, session: session, cache: cache)
        await next.loadIfNeeded()
        #expect(next.flights == [flight])
        #expect(await client.requestCount == 2)
    }

    @Test("A new session cannot reuse the previous session's flights, even with an identical token")
    func newSession() async {
        let client = CountingFlightsAPIClient(result: .success([RouteFixtures.flight()]))
        let session = SessionStore(storage: InMemoryTokenStorage(token: "token"))
        let cache = FlightsCache()
        await model(client: client, session: session, cache: cache).loadIfNeeded()
        session.endSession()
        session.beginSession(token: "token")
        await client.setResult(.success([]))
        let next = model(client: client, session: session, cache: cache)
        await next.loadIfNeeded()
        #expect(next.flights.isEmpty)
        #expect(await client.requestCount == 2)
    }

    @Test("Cached flights are classified using the current clock, not the cache's fetch time")
    func freshClassification() async {
        let flight = RouteFixtures.flight()
        let client = CountingFlightsAPIClient(result: .success([flight]))
        let session = SessionStore(storage: InMemoryTokenStorage(token: "token"))
        let cache = FlightsCache()
        await model(client: client, session: session, cache: cache).loadIfNeeded()
        let next = model(
            client: client,
            session: session,
            cache: cache,
            now: Fixtures.date("2026-09-06T12:00:00Z")
        )
        await next.loadIfNeeded()
        #expect(next.isShowingEmptyState)
        next.selectedCategory = .past
        #expect(next.items.map(\.id) == [flight.id])
        #expect(await client.requestCount == 1)
    }
}
