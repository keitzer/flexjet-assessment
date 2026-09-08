@testable import Flights
import Foundation
import Testing

@MainActor
@Suite("Flight request lifecycle")
struct FlightRequestLifecycleTests {
    private func model(client: FlightsAPIClient, session: SessionStore) -> FlightListViewModel {
        FlightListViewModel(
            apiClient: client,
            session: session,
            completion: FlightCompletionStore(storage: InMemoryCompletionStorage())
        )
    }

    @Test("An older response cannot overwrite a newer refresh")
    func latestRequestWins() async {
        let client = ControlledFlightsAPIClient()
        let model = model(client: client, session: SessionStore(storage: InMemoryTokenStorage(token: "token")))
        let first = Task { await model.load() }
        await client.waitForRequests(1)
        #expect(model.state == .loading)
        let second = Task { await model.load() }
        await client.waitForRequests(2)
        let flights = Flight.samples
        await client.finish(1, with: .success(flights))
        await second.value
        await client.finish(0, with: .success([]))
        await first.value
        #expect(model.state == .loaded)
        #expect(model.flights == flights)
    }

    @Test("An old 401 cannot sign out a new session", arguments: ["old-token", "new-token"])
    func oldSessionFailure(newToken: String) async {
        let client = ControlledFlightsAPIClient()
        let session = SessionStore(storage: InMemoryTokenStorage(token: "old-token"))
        let model = model(client: client, session: session)
        let request = Task { await model.load() }
        await client.waitForRequests(1)
        session.endSession()
        session.beginSession(token: newToken)
        await client.finish(0, with: .failure(.sessionExpired))
        await request.value
        #expect(session.token == newToken)
        #expect(model.state != .failed(.sessionExpired))
    }

    @Test("A response arriving after sign-out is discarded")
    func signedOutResponse() async {
        let client = ControlledFlightsAPIClient()
        let session = SessionStore(storage: InMemoryTokenStorage(token: "token"))
        let model = model(client: client, session: session)
        let request = Task { await model.load() }
        await client.waitForRequests(1)
        session.endSession()
        await client.finish(0, with: .success(Flight.samples))
        await request.value
        #expect(model.flights.isEmpty)
        #expect(!session.isSignedIn)
    }

    @Test("A cancelled initial load remains retryable without showing an error")
    func cancelledLoadCanRetry() async {
        let client = ControlledFlightsAPIClient()
        let model = model(client: client, session: SessionStore(storage: InMemoryTokenStorage(token: "token")))
        let request = Task { await model.loadIfNeeded() }
        await client.waitForRequests(1)
        request.cancel()
        await client.finish(0, with: .success(Flight.samples))
        await request.value
        #expect(model.state == .idle)
        #expect(model.flights.isEmpty)
        let retry = Task { await model.loadIfNeeded() }
        await client.waitForRequests(2)
        await client.finish(1, with: .success([]))
        await retry.value
        #expect(model.state == .loaded)
    }

    @Test("Cancelling refresh preserves the displayed flights")
    func cancelledRefreshKeepsData() async {
        let client = ControlledFlightsAPIClient()
        let model = model(client: client, session: SessionStore(storage: InMemoryTokenStorage(token: "token")))
        let initial = Task { await model.load() }
        await client.waitForRequests(1)
        await client.finish(0, with: .success(Flight.samples))
        await initial.value
        let existing = model.flights
        let refresh = Task { await model.load() }
        await client.waitForRequests(2)
        refresh.cancel()
        await client.finish(1, with: .success([]))
        await refresh.value
        #expect(model.state == .loaded)
        #expect(model.flights == existing)
    }
}
