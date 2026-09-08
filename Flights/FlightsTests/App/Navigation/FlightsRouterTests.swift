@testable import Flights
import Testing

@MainActor
@Suite("Flight navigation state")
struct FlightsRouterTests {
    @Test("Back on an empty stack is safe; selecting flights preserves their identity")
    func navigation() {
        let router = FlightsRouter()
        router.pop()
        #expect(router.path.isEmpty)
        let first = Fixtures.flight(id: "first", departure: "2026-09-05T12:00:00Z", arrival: "2026-09-05T18:00:00Z")
        let second = Fixtures.flight(id: "second", departure: "2026-09-06T12:00:00Z", arrival: "2026-09-06T18:00:00Z")
        router.showDetail(first)
        router.showDetail(second)
        #expect(router.path == [.detail(first), .detail(second)])
        router.pop()
        #expect(router.path == [.detail(first)])
        router.popToRoot()
        #expect(router.path.isEmpty)
    }
}
