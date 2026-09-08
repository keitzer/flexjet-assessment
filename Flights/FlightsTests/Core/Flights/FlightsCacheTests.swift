@testable import Flights
import Foundation
import Testing

@MainActor
@Suite("Session-scoped flights cache")
struct FlightsCacheTests {
    @Test("Older requests cannot overwrite a newer cache snapshot")
    func newestRequestWins() {
        let cache = FlightsCache()
        let revision = UUID()
        #expect(cache.flights(for: revision) == nil)
        let first = cache.beginRequest()
        let second = cache.beginRequest()
        let flights = [RouteFixtures.flight()]
        cache.save(flights, for: revision, requestID: second)
        cache.save([], for: revision, requestID: first)
        #expect(cache.flights(for: revision) == flights)
        #expect(cache.flights(for: UUID()) == nil)
    }
}
