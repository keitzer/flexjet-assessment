/// An allowlist of reporting identifiers; never carries credentials, tokens or free-form input.
nonisolated struct AnalyticsContext: Equatable, Sendable {
    let properties: [String: AnalyticsValue]
    static let empty = Self(properties: [:])

    static func route(_ route: RouteIdentity) -> Self {
        Self(properties: [
            "origin_iata": .string(route.origin),
            "destination_iata": .string(route.destination)
        ])
    }

    static func flight(_ flight: Flight) -> Self {
        var properties = route(RouteIdentity(flight: flight)).properties
        properties["flight_id"] = .string(flight.id)
        if let number = flight.flightNumber {
            properties["flight_number"] = .string(number)
        }
        return Self(properties: properties)
    }
}
