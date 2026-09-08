import Foundation
import Synchronization

/// Persists the bearer token between launches.
///
/// Abstracted so tests and previews can run against memory instead of the Keychain, which is
/// unavailable in a SwiftUI preview process.
nonisolated protocol TokenStorage: Sendable {
    func load() -> String?
    func save(_ token: String)
    func clear()
}

/// Non-persistent storage for previews and tests.
nonisolated final class InMemoryTokenStorage: TokenStorage {
    private let token: Mutex<String?>

    init(token: String? = nil) {
        self.token = Mutex(token)
    }

    func load() -> String? {
        token.withLock { $0 }
    }

    func save(_ token: String) {
        self.token.withLock { $0 = token }
    }

    func clear() {
        token.withLock { $0 = nil }
    }
}
