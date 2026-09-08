@testable import Flights
import Foundation
import Testing

@MainActor
@Suite("Completion persistence")
struct CompletionStorageTests {
    @Test("Completion survives reopening and toggles do not affect another flight")
    func roundTrip() throws {
        let suite = "CompletionStorageTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = UserDefaultsCompletionStorage(defaults: defaults)
        #expect(storage.loadCompletedIDs().isEmpty)
        let first = FlightCompletionStore(storage: storage)
        first.setComplete(true, for: "FL001")
        first.setComplete(true, for: "FL001")
        first.setComplete(true, for: "FL002")
        let reopened = FlightCompletionStore(storage: storage)
        #expect(reopened.completedIDs == ["FL001", "FL002"])
        reopened.toggle("FL001")
        #expect(FlightCompletionStore(storage: storage).completedIDs == ["FL002"])
    }
}
