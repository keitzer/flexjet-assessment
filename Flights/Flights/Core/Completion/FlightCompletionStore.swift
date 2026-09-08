import Foundation
import Observation

/// Tracks which flights the user has marked complete.
///
/// Shared through the environment so the detail screen's Complete button and the list row's
/// checkmark read the same state — which is what makes the checkmark update when the user
/// returns from the detail screen.
@Observable
@MainActor
final class FlightCompletionStore {
    private(set) var completedIDs: Set<String>

    private let storage: CompletionPersisting

    init(storage: CompletionPersisting = UserDefaultsCompletionStorage()) {
        self.storage = storage
        self.completedIDs = storage.loadCompletedIDs()
    }

    func isComplete(_ flightID: String) -> Bool {
        completedIDs.contains(flightID)
    }

    func setComplete(_ isComplete: Bool, for flightID: String) {
        if isComplete {
            completedIDs.insert(flightID)
        } else {
            completedIDs.remove(flightID)
        }
        storage.save(completedIDs)
    }

    func toggle(_ flightID: String) {
        setComplete(!isComplete(flightID), for: flightID)
    }
}
