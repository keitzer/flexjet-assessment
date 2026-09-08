import Foundation
import Synchronization

/// Persists the set of flight IDs the user has marked complete.
///
/// The service exposes no write endpoint, so completion is device-local state. Kept behind a
/// protocol so tests and previews can run without touching `UserDefaults`.
nonisolated protocol CompletionPersisting: Sendable {
    func loadCompletedIDs() -> Set<String>
    func save(_ ids: Set<String>)
}

/// `UserDefaults`-backed storage. Completion is a non-sensitive preference, so unlike the auth
/// token it does not warrant the Keychain.
///
/// `@unchecked Sendable` because `UserDefaults` predates `Sendable` but is documented as
/// thread-safe; the struct adds no mutable state of its own.
nonisolated struct UserDefaultsCompletionStorage: CompletionPersisting, @unchecked Sendable {
    private let key = "completedFlightIDs"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadCompletedIDs() -> Set<String> {
        Set(defaults.stringArray(forKey: key) ?? [])
    }

    func save(_ ids: Set<String>) {
        defaults.set(Array(ids), forKey: key)
    }
}

/// Non-persistent storage for previews and tests.
nonisolated final class InMemoryCompletionStorage: CompletionPersisting {
    private let ids: Mutex<Set<String>>

    init(ids: Set<String> = []) {
        self.ids = Mutex(ids)
    }

    func loadCompletedIDs() -> Set<String> {
        ids.withLock { $0 }
    }

    func save(_ ids: Set<String>) {
        self.ids.withLock { $0 = ids }
    }
}
