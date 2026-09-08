import Foundation

/// Directional airport identity, independent of flight IDs and inconsistent service labels.
nonisolated struct RouteIdentity: Codable, Hashable, Sendable {
    let origin: String
    let destination: String

    init(origin: String, destination: String) {
        self.origin = origin.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        self.destination = destination.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }

    init(flight: Flight) {
        self.init(origin: flight.origin.iata, destination: flight.destination.iata)
    }

    var title: String { "\(origin) to \(destination)" }

    func matches(_ flight: Flight) -> Bool {
        self == Self(flight: flight)
    }
}

/// Save endpoint labels with the identity so a route remains visible even with no current flights.
nonisolated struct FavoriteRoute: Codable, Hashable, Identifiable, Sendable {
    let id: RouteIdentity
    let originLabel: String
    let destinationLabel: String

    init(flight: Flight) {
        id = RouteIdentity(flight: flight)
        originLabel = flight.origin.label
        destinationLabel = flight.destination.label
    }
}
