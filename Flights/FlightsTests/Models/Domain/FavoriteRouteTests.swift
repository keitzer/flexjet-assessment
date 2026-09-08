@testable import Flights
import Foundation
import Testing

@Suite("Directional route identity")
struct FavoriteRouteTests {
    @Test("Repeated flights share a route despite differing IDs and labels")
    func matchesCodes() {
        let first = RouteFixtures.flight(id: "first")
        let second = RouteFixtures.flight(id: "second", label: "An inconsistent service label (JFK)")
        let route = RouteIdentity(flight: first)
        #expect(route.matches(second))
        #expect(route.title == "SFO to SEA")
        #expect(FavoriteRoute(flight: first).originLabel == first.origin.label)
        #expect(FavoriteRoute(flight: first).destinationLabel == first.destination.label)
    }

    @Test("The reverse route and other airports are independent")
    func directionMatters() {
        let route = RouteIdentity(flight: RouteFixtures.flight())
        #expect(!route.matches(RouteFixtures.flight(origin: "SEA", destination: "SFO")))
        #expect(!route.matches(RouteFixtures.flight(destination: "LAX")))
        #expect(!route.matches(RouteFixtures.flight(origin: "JFK")))
    }

    @Test("Code casing and surrounding whitespace do not split favorites")
    func normalizedIdentity() {
        let route = RouteIdentity(origin: " sfo\n", destination: "sea ")
        #expect(route == RouteIdentity(flight: RouteFixtures.flight()))
    }

    @Test("A saved route can round-trip independently of a flight response")
    func codableRoundTrip() throws {
        let route = FavoriteRoute(flight: RouteFixtures.flight())
        let data = try JSONEncoder().encode(route)
        #expect(try JSONDecoder().decode(FavoriteRoute.self, from: data) == route)
    }
}
