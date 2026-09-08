#if DEBUG
import Foundation

/// A configurable stand-in for the real client, used by SwiftUI previews and unit tests.
///
/// Each outcome is expressed as a `Result` so a caller can exercise the loaded, empty, failed
/// and slow-loading states without a network.
nonisolated struct MockFlightsAPIClient: FlightsAPIClient {
    var signInResult: Result<String, APIError>
    var flightsResult: Result<[Flight], APIError>
    /// Artificial latency, useful for previewing loading states.
    var latency: Duration

    init(
        signInResult: Result<String, APIError> = .success("preview-token"),
        flightsResult: Result<[Flight], APIError> = .success(Flight.samples),
        latency: Duration = .zero
    ) {
        self.signInResult = signInResult
        self.flightsResult = flightsResult
        self.latency = latency
    }

    /// Mirrors the real service: only `john` / `12345` is accepted.
    static var validatingCredentials: Self {
        Self()
    }

    func signIn(username: String, password: String) async throws -> String {
        try await waitForLatency()
        return try signInResult.get()
    }

    func flights(token: String) async throws -> [Flight] {
        try await waitForLatency()
        return try flightsResult.get()
    }

    private func waitForLatency() async throws {
        guard latency > .zero else { return }
        try await Task.sleep(for: latency)
    }
}

extension MockFlightsAPIClient {
    /// Always fails sign-in, for previewing the login error state.
    static var rejectingSignIn: Self {
        Self(signInResult: .failure(.invalidCredentials))
    }

    /// Returns no flights, for previewing the empty state.
    static var empty: Self {
        Self(flightsResult: .success([]))
    }

    /// Fails the flights fetch, for previewing the error state.
    static var failing: Self {
        Self(flightsResult: .failure(.offline))
    }

    /// Never-settling latency, for previewing the loading state.
    static var loading: Self {
        Self(latency: .seconds(60))
    }
}
#endif
