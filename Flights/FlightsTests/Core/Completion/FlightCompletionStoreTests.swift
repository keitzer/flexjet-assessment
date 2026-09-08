@testable import Flights
import Testing

@MainActor
@Suite("Completion state")
struct FlightCompletionStoreTests {
    @Test("Marking a flight complete persists through the storage layer")
    func persistsCompletion() {
        let storage = InMemoryCompletionStorage()
        let store = FlightCompletionStore(storage: storage)
        #expect(!store.isComplete("FL001"))

        store.setComplete(true, for: "FL001")
        #expect(store.isComplete("FL001"))
        #expect(storage.loadCompletedIDs() == ["FL001"])

        // A new store over the same storage sees the saved value.
        #expect(FlightCompletionStore(storage: storage).isComplete("FL001"))
    }

    @Test("Toggling reverses the current state")
    func togglesCompletion() {
        let store = FlightCompletionStore(storage: InMemoryCompletionStorage())
        store.toggle("FL001")
        #expect(store.isComplete("FL001"))
        store.toggle("FL001")
        #expect(!store.isComplete("FL001"))
    }

    @Test("Completing one flight leaves others untouched")
    func isolatesFlights() {
        let store = FlightCompletionStore(storage: InMemoryCompletionStorage(ids: ["FL001"]))
        store.setComplete(true, for: "FL002")
        #expect(store.completedIDs == ["FL001", "FL002"])
    }
}
