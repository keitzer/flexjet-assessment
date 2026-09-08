@testable import Flights

/// Deliberately ignores cancellation so tests can release a late success or failure.
actor ControlledSignInAPIClient: FlightsAPIClient {
    private var pending: CheckedContinuation<String, any Error>?
    private var waiter: CheckedContinuation<Void, Never>?
    private(set) var callCount = 0

    func signIn(username: String, password: String) async throws -> String {
        callCount += 1
        return try await withCheckedThrowingContinuation { continuation in
            pending = continuation
            waiter?.resume()
            waiter = nil
        }
    }

    func flights(token: String) async throws -> [Flight] { [] }

    func waitForRequest() async {
        guard pending == nil else { return }
        await withCheckedContinuation { waiter = $0 }
    }

    func finish(succeeds: Bool) {
        if succeeds {
            pending?.resume(returning: "late-token")
        } else {
            pending?.resume(throwing: APIError.invalidCredentials)
        }
        pending = nil
    }
}
