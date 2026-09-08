import Foundation
import Observation

/// App-wide authentication state.
///
/// Owns the bearer token and is the single place that decides whether the app shows the login
/// screen or the main tabs. Feature view models ask it for the token rather than storing copies,
/// so a sign-out invalidates every screen at once.
///
/// Marked `@MainActor` explicitly even though the target defaults to main-actor isolation, so the
/// requirement is visible at the declaration.
@Observable
@MainActor
final class SessionStore {
    /// The current token, or `nil` when signed out.
    private(set) var token: String?
    /// Distinguishes session lifetimes even when the service returns the same token again.
    private(set) var revision = UUID()

    private let storage: TokenStorage
    private let analytics: Analytics

    init(storage: TokenStorage = KeychainTokenStorage(), analytics: Analytics = .disabled) {
        self.analytics = analytics
        self.storage = storage
        // Restoring here means a returning user skips the login screen.
        self.token = storage.load()
    }

    var isSignedIn: Bool {
        token != nil
    }

    func beginSession(token: String) {
        let wasSignedIn = isSignedIn
        revision = UUID()
        storage.save(token)
        self.token = token
        analytics.change(.session, page: .app, from: .bool(wasSignedIn), to: .bool(true))
    }

    /// Clears the session. Called on explicit sign-out and whenever the service rejects the
    /// token with a 401.
    func endSession() {
        let wasSignedIn = isSignedIn
        revision = UUID()
        storage.clear()
        token = nil
        analytics.change(.session, page: .app, from: .bool(wasSignedIn), to: .bool(false))
    }
}
