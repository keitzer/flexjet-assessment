import Foundation

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
nonisolated final class InMemoryTokenStorage: TokenStorage, @unchecked Sendable {
    private let lock = NSLock()
    private var token: String?

    init(token: String? = nil) {
        self.token = token
    }

    func load() -> String? {
        lock.withLock { token }
    }

    func save(_ token: String) {
        lock.withLock { self.token = token }
    }

    func clear() {
        lock.withLock { token = nil }
    }
}
