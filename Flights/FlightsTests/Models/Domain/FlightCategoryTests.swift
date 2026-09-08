@testable import Flights
import Testing

@Suite("Flight category selection")
struct FlightCategoryTests {
    @Test("Both flight lists expose Upcoming then Past with distinct stable selection identities")
    func selectionOptions() {
        #expect(FlightCategory.allCases.map(\.title) == ["Upcoming", "Past"])
        #expect(FlightCategory.allCases.map(\.id) == ["upcoming", "past"])
    }
}
