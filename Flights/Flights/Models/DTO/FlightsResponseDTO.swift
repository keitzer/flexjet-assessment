import Foundation

/// Isolates decoding failures to individual records while requiring a valid top-level array.
nonisolated struct FlightsResponseDTO: Decodable {
    let flights: [Flight]

    init(from decoder: any Decoder) throws {
        var records = try decoder.unkeyedContainer()
        var flights: [Flight] = []
        while !records.isAtEnd {
            try Task.checkCancellation()
            // Consume the whole element before decoding it so a bad field cannot stall the loop.
            let record = try records.superDecoder()
            if let dto = try? FlightDTO(from: record), let flight = Flight(dto: dto) {
                flights.append(flight)
            }
        }
        self.flights = flights
    }
}
