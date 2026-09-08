import Foundation

/// The app's entire surface onto the flights service.
///
/// Views and view models depend on this protocol, never on `URLSession`, so previews and tests
/// can substitute a stub without a network. The token is passed explicitly rather than held by
/// the client, which keeps the client stateless and leaves session ownership in one place.
nonisolated protocol FlightsAPIClient: Sendable {
    /// Authenticates and returns a bearer token.
    /// - Throws: `APIError.invalidCredentials` when the pair is rejected.
    func signIn(username: String, password: String) async throws -> String

    /// Fetches all flights visible to the authenticated user.
    /// - Throws: `APIError.sessionExpired` when the token is no longer accepted.
    func flights(token: String) async throws -> [Flight]
}
