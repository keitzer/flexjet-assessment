@testable import Flights
import Foundation
import Testing

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
        #expect(model.destinationLabel == "New York (JFK)")
        #expect(model.fields.map(\.id) == [
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
