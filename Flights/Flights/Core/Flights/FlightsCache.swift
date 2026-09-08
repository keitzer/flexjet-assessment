import Foundation

/// An in-memory snapshot scoped to a session lifetime, including successful empty responses.
/// Request identities prevent an older response from replacing a newer refresh's cache.
@MainActor
final class FlightsCache {
    private var snapshot: [Flight]?
    private var sessionRevision: UUID?
    private var latestRequestID: UUID?

    func flights(for revision: UUID) -> [Flight]? {
        sessionRevision == revision ? snapshot : nil
    }

    func beginRequest() -> UUID {
        let requestID = UUID()
        latestRequestID = requestID
        return requestID
    }

    func save(_ flights: [Flight], for revision: UUID, requestID: UUID) {
        guard requestID == latestRequestID else { return }
        snapshot = flights
        sessionRevision = revision
    }
}
