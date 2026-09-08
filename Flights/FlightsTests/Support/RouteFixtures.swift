@testable import Flights
import Foundation

enum RouteFixtures {
    static func flight(
        id: String = "flight",
        origin: String = "SFO",
        destination: String = "SEA",
        departure: String = "2026-09-05T12:00:00Z",
        label: String = "San Francisco (SFO)"
    ) -> Flight {
        let date = Fixtures.date(departure)
        return Flight(
            id: id,
            tripNumber: "trip",
            flightNumber: "UA100",
            tailNumber: "N100UA",
            origin: Airport(label: label, iata: origin),
            destination: Airport(label: destination, iata: destination),
            departure: date,
            arrival: date.addingTimeInterval(3600),
            price: 100
        )
    }
}
