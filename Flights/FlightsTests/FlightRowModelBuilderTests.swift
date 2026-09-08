@testable import Flights
import Foundation
import Testing

@Suite("Flight row presentation")
struct FlightRowModelBuilderTests {
    private let builder = FlightRowModelBuilder(
        formatter: Fixtures.formatter(in: Fixtures.eastern),
        classifier: FlightClassifier(calendar: Fixtures.calendar(in: Fixtures.eastern))
    )
    private let now = Fixtures.date("2026-09-05T12:00:00Z")

    @Test("An upcoming row shows the time range and no checkmark")
    func upcomingRow() {
        let flight = Fixtures.flight(departure: "2026-09-08T15:00:00Z", arrival: "2026-09-08T18:00:00Z")
        let row = builder.make(from: flight, isComplete: false, now: now)
        #expect(row.title == "Las Vegas to New York")
        #expect(Fixtures.normalized(row.subtitle) == "11:00 AM - 2:00 PM")
        #expect(!row.showsCompletion)
        #expect(!row.isPast)
    }

    @Test("A past row shows the flight number and a checkmark")
    func pastRow() {
        let flight = Fixtures.flight(departure: "2026-09-01T15:00:00Z", arrival: "2026-09-01T18:00:00Z")
        let row = builder.make(from: flight, isComplete: true, now: now)
        #expect(row.subtitle == "UA890")
        #expect(row.showsCompletion)
        #expect(row.isComplete)
        #expect(row.isPast)
    }

    @Test("A past row falls back to the tail number when the flight number is null")
    func pastRowWithoutFlightNumber() {
        let flight = Fixtures.flight(
            departure: "2026-09-01T15:00:00Z",
            arrival: "2026-09-01T18:00:00Z",
            flightNumber: nil
        )
        #expect(builder.make(from: flight, isComplete: false, now: now).subtitle == "N987UA")
    }

    @Test("Only an upcoming flight departing today carries the badge")
    func badgeOnlyForTodayUpcoming() {
        let today = Fixtures.flight(departure: "2026-09-05T22:00:00Z", arrival: "2026-09-06T02:00:00Z")
        let departed = Fixtures.flight(departure: "2026-09-05T11:00:00Z", arrival: "2026-09-05T14:00:00Z")
        let tomorrow = Fixtures.flight(departure: "2026-09-06T15:00:00Z", arrival: "2026-09-06T18:00:00Z")
        #expect(builder.make(from: today, isComplete: false, now: now).showsTodayBadge)
        #expect(!builder.make(from: departed, isComplete: false, now: now).showsTodayBadge)
        #expect(!builder.make(from: tomorrow, isComplete: false, now: now).showsTodayBadge)
    }
}

@Suite("Flight detail presentation")
struct FlightDetailPresenterTests {
    private let presenter = FlightDetailPresenter(formatter: Fixtures.formatter(in: Fixtures.eastern))
    private let now = Fixtures.date("2026-09-19T12:00:00Z")

    @Test("Builds the fields the design lists, in order")
    func buildsFields() {
        let flight = Fixtures.flight(departure: "2026-09-05T12:00:00Z", arrival: "2026-09-05T18:00:00Z")
        let model = presenter.make(from: flight, now: now)
        #expect(model.title == "LAS to JFK")
        #expect(model.originLabel == "Las Vegas (LAS)")
        #expect(model.fields.map(\.label) == [
            "Departure Date", "Trip Number", "Flight Number", "Tail Number", "Price"
        ])
        #expect(model.fields.map(\.value) == ["Sep 5 (2w ago)", "1234567", "UA890", "N987UA", "$349"])
    }

    @Test("A null flight number renders as a placeholder rather than an empty row")
    func placeholderForNullFlightNumber() {
        let flight = Fixtures.flight(
            departure: "2026-09-05T12:00:00Z",
            arrival: "2026-09-05T18:00:00Z",
            flightNumber: nil
        )
        let value = presenter.make(from: flight, now: now).fields.first { $0.label == "Flight Number" }
        #expect(value?.value == FlightDetailPresenter.missingValue)
    }
}
