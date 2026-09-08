@testable import Flights
import Testing

@MainActor
@Suite("Completion propagation between screens")
struct CompletionPropagationTests {
    @Test("Completion is available only after departure", arguments: [
        "2026-09-01T11:59:59Z",
        "2026-09-01T12:00:00Z",
        "2026-09-01T12:00:01Z"
    ])
    func completionEligibility(instant: String) {
        let flight = Fixtures.flight(departure: "2026-09-01T12:00:00Z", arrival: "2026-09-01T15:00:00Z")
        let now = Fixtures.date(instant)
        let eligible = instant == "2026-09-01T12:00:01Z"
        let storage = InMemoryCompletionStorage()
        let completion = FlightCompletionStore(storage: storage)
        let detail = FlightDetailViewModel(flight: flight, completion: completion) { now }

        #expect(detail.canToggleCompletion == eligible)
        detail.toggleCompletion()
        #expect(detail.isComplete == eligible)
        #expect(FlightCompletionStore(storage: storage).isComplete(flight.id) == eligible)
        detail.toggleCompletion()
        #expect(!detail.isComplete)
    }

    @Test("Detail toggles update the loaded list and persist without fetching again")
    func detailUpdatesList() async throws {
        let flight = Fixtures.flight(departure: "2026-09-01T12:00:00Z", arrival: "2026-09-01T15:00:00Z")
        let now = Fixtures.date("2026-09-05T12:00:00Z")
        let storage = InMemoryCompletionStorage()
        let completion = FlightCompletionStore(storage: storage)
        let list = FlightListViewModel(
            apiClient: MockFlightsAPIClient(flightsResult: .success([flight])),
            session: SessionStore(storage: InMemoryTokenStorage(token: "token")),
            completion: completion
        ) { now }
        let detail = FlightDetailViewModel(flight: flight, completion: completion) { now }
        await list.load()
        list.selectedCategory = .past
        #expect(try #require(list.items.first).model.isComplete == false)
        detail.toggleCompletion()
        #expect(detail.isComplete)
        #expect(try #require(list.items.first).model.isComplete)
        #expect(FlightCompletionStore(storage: storage).isComplete(flight.id))
        detail.toggleCompletion()
        #expect(!detail.isComplete)
        #expect(try #require(list.items.first).model.isComplete == false)
        #expect(!FlightCompletionStore(storage: storage).isComplete(flight.id))
    }
}
