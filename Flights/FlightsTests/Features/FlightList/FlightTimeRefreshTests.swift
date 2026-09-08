@testable import Flights
import Foundation
import Testing

@MainActor
@Suite("Refreshing loaded flight presentation without networking")
struct FlightTimeRefreshTests {
    @Test("Midnight adds Today and departure moves the row to Past and enables completion")
    func refreshAcrossBoundaries() async throws {
        let clock = TestClock(Fixtures.date("2026-09-06T03:59:59Z"))
        let flight = Fixtures.flight(departure: "2026-09-06T04:00:10Z", arrival: "2026-09-06T06:00:00Z")
        let classifier = FlightClassifier(calendar: Fixtures.calendar(in: Fixtures.eastern))
        let formatter = Fixtures.formatter(in: Fixtures.eastern)
        let completion = FlightCompletionStore(storage: InMemoryCompletionStorage())
        let list = FlightListViewModel(
            apiClient: MockFlightsAPIClient(flightsResult: .success([flight])),
            session: SessionStore(storage: InMemoryTokenStorage(token: "token")),
            completion: completion,
            classifier: classifier,
            builder: FlightRowModelBuilder(formatter: formatter, classifier: classifier),
            now: clock.now
        )
        let detail = FlightDetailViewModel(
            flight: flight,
            completion: completion,
            presenter: FlightDetailPresenter(formatter: formatter),
            classifier: classifier,
            now: clock.now
        )
        await list.load()
        #expect(try #require(list.items.first).model.showsTodayBadge == false)
        #expect(!detail.showsTodayBadge)
        clock.set(Fixtures.date("2026-09-06T04:00:00Z"))
        list.refreshTime()
        detail.refreshTime()
        #expect(try #require(list.items.first).model.showsTodayBadge)
        #expect(detail.showsTodayBadge)
        #expect(!detail.canToggleCompletion)
        clock.set(Fixtures.date("2026-09-06T04:00:11Z"))
        list.refreshTime()
        detail.refreshTime()
        #expect(list.isShowingEmptyState)
        #expect(!detail.showsTodayBadge)
        #expect(detail.canToggleCompletion)
        list.selectedCategory = .past
        #expect(list.items.map(\.id) == [flight.id])
        #expect(detail.model.fields.first?.value.hasPrefix("Sep 6") == true)
    }
}
