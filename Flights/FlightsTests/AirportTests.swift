@testable import Flights
import Testing

@Suite("Airport label parsing")
struct AirportTests {
    @Test("Strips a trailing airport code from the label")
    func stripsTrailingCode() {
        #expect(Airport(label: "Las Vegas (LAS)", iata: "LAS").city == "Las Vegas")
    }

    @Test("Keeps a label that has no trailing code")
    func keepsPlainLabel() {
        #expect(Airport(label: "Rome", iata: "FCO").city == "Rome")
    }

    @Test("Handles the service's 72-character origin label")
    func handlesVerboseLabel() {
        let label = "The Beautiful and Historic City of New York Where Dreams Come True (JFK)"
        let airport = Airport(label: label, iata: "SFO")
        #expect(airport.city == "The Beautiful and Historic City of New York Where Dreams Come True")
        // The label's code and the IATA field disagree in the real data; both are preserved.
        #expect(airport.iata == "SFO")
        #expect(airport.label == label)
    }

    @Test("Leaves a label that is only a code untouched")
    func keepsCodeOnlyLabel() {
        #expect(Airport(label: "(LAS)", iata: "LAS").city == "(LAS)")
    }

    @Test("Only the final parenthesised group is removed")
    func stripsOnlyTrailingGroup() {
        #expect(Airport(label: "Paris (CDG) Terminal (2E)", iata: "CDG").city == "Paris (CDG) Terminal")
    }

    @Test("Route titles and codes read as the design specifies")
    func buildsRouteStrings() {
        let flight = Fixtures.flight(
            departure: "2026-09-05T12:00:00.000Z",
            arrival: "2026-09-05T18:00:00.000Z"
        )
        #expect(flight.routeTitle == "Las Vegas to New York")
        #expect(flight.routeCode == "LAS to JFK")
    }
}
