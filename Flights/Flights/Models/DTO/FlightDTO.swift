import Foundation

/// Wire representation of a flight, mirroring the service's JSON exactly.
///
/// Every field is optional so that a single malformed or newly-nullable field cannot fail the
/// decode of the whole response. Validation happens in `Flight.init(dto:)`, which is the one
/// place that decides what a usable flight is.
nonisolated struct FlightDTO: Decodable, Sendable {
    let id: String?
    let tripNumber: String?
    let flightNumber: String?
    let tailNumber: String?
    let origin: String?
    let originIata: String?
    let destination: String?
    let destinationIata: String?
    let departure: String?
    let arrival: String?
    let price: Int?
}

nonisolated extension Flight {
    /// Maps a wire object to a domain flight, returning `nil` when required data is missing.
    ///
    /// `flightNumber` is deliberately *not* required: the service returns `null` for it on at
    /// least one flight, and the design has a layout for a row without one. Everything else is
    /// needed to render a correct row, so a record missing any of it is dropped rather than
    /// shown with placeholder text.
    init?(dto: FlightDTO) {
        guard let id = dto.id,
              let tripNumber = dto.tripNumber,
              let tailNumber = dto.tailNumber,
              let origin = dto.origin,
              let originIata = dto.originIata,
              let destination = dto.destination,
              let destinationIata = dto.destinationIata,
              let departureString = dto.departure,
              let arrivalString = dto.arrival,
              let price = dto.price,
              let departure = ISO8601Parsing.date(from: departureString),
              let arrival = ISO8601Parsing.date(from: arrivalString)
        else {
            return nil
        }
        self.init(
            id: id,
            tripNumber: tripNumber,
            flightNumber: dto.flightNumber,
            tailNumber: tailNumber,
            origin: Airport(label: origin, iata: originIata),
            destination: Airport(label: destination, iata: destinationIata),
            departure: departure,
            arrival: arrival,
            price: Decimal(price)
        )
    }
}
