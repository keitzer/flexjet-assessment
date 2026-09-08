@testable import Flights
import Foundation
import Testing

@Suite("Decoding and mapping flights")
struct FlightMappingTests {
    private func decode(_ json: String) throws -> [Flight] {
        let data = Data(json.utf8)
        return try JSONDecoder().decode([FlightDTO].self, from: data).compactMap(Flight.init(dto:))
    }

    /// A verbatim record from the live service.
    private let validJSON = """
    [{"id":"FL001","tripNumber":"1000001","flightNumber":"UA456","tailNumber":"N456UA",
      "origin":"Chicago (ORD)","originIata":"ORD","destination":"Miami (MIA)","destinationIata":"MIA",
      "departure":"2026-08-29T09:20:00.000Z","arrival":"2026-08-29T12:20:00.000Z","price":10800}]
    """

    @Test("Maps a well-formed record")
    func mapsValidFlight() throws {
        let flights = try decode(validJSON)
        let flight = try #require(flights.first)
        #expect(flight.id == "FL001")
        #expect(flight.flightNumber == "UA456")
        #expect(flight.origin.city == "Chicago")
        #expect(flight.destination.iata == "MIA")
        #expect(flight.price == 10800)
        #expect(flight.departure == Fixtures.date("2026-08-29T09:20:00Z"))
    }

    @Test("Keeps a flight whose flight number is null")
    func keepsNullFlightNumber() throws {
        let json = validJSON.replacingOccurrences(of: "\"UA456\"", with: "null")
        let flight = try #require(try decode(json).first)
        #expect(flight.flightNumber == nil)
        #expect(flight.tailNumber == "N456UA")
    }

    @Test("Drops a record missing a required field rather than failing the whole response")
    func dropsIncompleteRecord() throws {
        let broken = """
        [{"id":"FL001","tripNumber":"1000001","tailNumber":"N456UA",
          "origin":"Chicago (ORD)","originIata":"ORD","destination":"Miami (MIA)","destinationIata":"MIA",
          "departure":"2026-08-29T09:20:00.000Z","arrival":"2026-08-29T12:20:00.000Z"}]
        """
        #expect(try decode(broken).isEmpty)
    }

    @Test("One malformed record does not discard the valid ones")
    func keepsValidRecordsAlongsideBadOnes() throws {
        let mixed = """
        [{"id":"BAD","departure":"nonsense"},
         {"id":"FL001","tripNumber":"1000001","flightNumber":"UA456","tailNumber":"N456UA",
          "origin":"Chicago (ORD)","originIata":"ORD","destination":"Miami (MIA)","destinationIata":"MIA",
          "departure":"2026-08-29T09:20:00.000Z","arrival":"2026-08-29T12:20:00.000Z","price":10800}]
        """
        let flights = try decode(mixed)
        #expect(flights.count == 1)
        #expect(flights.first?.id == "FL001")
    }

    @Test("Drops a record whose departure cannot be parsed")
    func dropsUnparsableDate() throws {
        let json = validJSON.replacingOccurrences(of: "2026-08-29T09:20:00.000Z", with: "29/08/2026")
        #expect(try decode(json).isEmpty)
    }

    @Test("An unknown extra field does not break decoding")
    func toleratesUnknownFields() throws {
        let json = validJSON.replacingOccurrences(of: "\"price\":10800", with: "\"price\":10800,\"gate\":\"B12\"")
        #expect(try decode(json).count == 1)
    }
}
