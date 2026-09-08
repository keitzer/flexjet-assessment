@testable import Flights
import Foundation

/// Tests decide exactly when requests finish, including services that ignore task cancellation.
actor ControlledFlightsAPIClient: FlightsAPIClient {
    private var requests: [CheckedContinuation<[Flight], any Error>] = []
    private var waiters: [Int: CheckedContinuation<Void, Never>] = [:]

    func signIn(username: String, password: String) async throws -> String { "test-token" }

    func flights(token: String) async throws -> [Flight] {
        try await withCheckedThrowingContinuation { continuation in
            requests.append(continuation)
            waiters.removeValue(forKey: requests.count)?.resume()
        }
    }

    func waitForRequests(_ count: Int) async {
        guard requests.count < count else { return }
        await withCheckedContinuation { waiters[count] = $0 }
    }

    func finish(_ index: Int, with result: Result<[Flight], APIError>) {
        requests[index].resume(with: result.mapError { $0 as any Error })
    }
}

nonisolated struct CancelledAPIClient: FlightsAPIClient {
    func signIn(username: String, password: String) async throws -> String { throw CancellationError() }
    func flights(token: String) async throws -> [Flight] { throw CancellationError() }
}
