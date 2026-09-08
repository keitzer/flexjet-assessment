@testable import Flights
import Foundation
import Testing

@MainActor
@Suite("Flights screen behaviour")
struct FlightListViewModelTests {
    private let now = Fixtures.date("2026-09-05T12:00:00Z")

    private func makeViewModel(
        client: FlightsAPIClient,
        token: String? = "token",
        completedIDs: Set<String> = []
    ) -> (model: FlightListViewModel, session: SessionStore) {
        let session = SessionStore(storage: InMemoryTokenStorage(token: token))
        let completion = FlightCompletionStore(storage: InMemoryCompletionStorage(ids: completedIDs))
        let model = FlightListViewModel(
            apiClient: client,
            session: session,
            completion: completion,
            classifier: FlightClassifier(calendar: Fixtures.calendar(in: Fixtures.eastern)),
            builder: FlightRowModelBuilder(
                formatter: Fixtures.formatter(in: Fixtures.eastern),
                classifier: FlightClassifier(calendar: Fixtures.calendar(in: Fixtures.eastern))
            ),
            now: { [now] in now }
        )
        return (model, session)
    }

    private var flights: [Flight] {
        [
            Fixtures.flight(id: "future", departure: "2026-09-08T15:00:00Z", arrival: "2026-09-08T18:00:00Z"),
            Fixtures.flight(id: "past", departure: "2026-09-01T15:00:00Z", arrival: "2026-09-01T18:00:00Z")
        ]
    }

    @Test("A successful load splits flights across the two segments")
    func loadsAndPartitions() async {
        let (model, _) = makeViewModel(client: MockFlightsAPIClient(flightsResult: .success(flights)))
        await model.load()

        #expect(model.state == .loaded)
        #expect(model.visibleFlights.map(\.id) == ["future"])
        model.selectedCategory = .past
        #expect(model.visibleFlights.map(\.id) == ["past"])
    }

    @Test("An empty response reports the empty state rather than an error")
    func reportsEmptyState() async {
        let (model, _) = makeViewModel(client: MockFlightsAPIClient(flightsResult: .success([])))
        await model.load()
        #expect(model.state == .loaded)
        #expect(model.isShowingEmptyState)
    }

    @Test("A transport failure surfaces as an error state")
    func reportsFailure() async {
        let (model, _) = makeViewModel(client: MockFlightsAPIClient(flightsResult: .failure(.offline)))
        await model.load()
        #expect(model.state == .failed(.offline))
    }

    @Test("A rejected token ends the session so the app returns to login")
    func expiredTokenSignsOut() async {
        let (model, session) = makeViewModel(
            client: MockFlightsAPIClient(flightsResult: .failure(.sessionExpired))
        )
        #expect(session.isSignedIn)
        await model.load()
        #expect(!session.isSignedIn)
        #expect(model.state == .failed(.sessionExpired))
    }

    @Test("Loading without a token fails instead of calling the service")
    func requiresToken() async {
        let (model, _) = makeViewModel(client: MockFlightsAPIClient(), token: nil)
        await model.load()
        #expect(model.state == .failed(.sessionExpired))
    }

    @Test("Rows reflect completion state from the shared store")
    func rowsReflectCompletion() async {
        let (model, _) = makeViewModel(
            client: MockFlightsAPIClient(flightsResult: .success(flights)),
            completedIDs: ["past"]
        )
        await model.load()
        model.selectedCategory = .past
        #expect(model.items.first?.model.isComplete == true)
    }

    @Test("loadIfNeeded fetches once and does not refetch")
    func loadsOnlyOnce() async {
        let (model, _) = makeViewModel(client: MockFlightsAPIClient(flightsResult: .success(flights)))
        await model.loadIfNeeded()
        #expect(model.state == .loaded)
        await model.loadIfNeeded()
        #expect(model.flights.count == 2)
    }
}
