#if DEBUG
import Foundation

/// A route used to build preview and test fixtures.
nonisolated struct SampleRoute {
    let origin: String
    let originIata: String
    let destination: String
    let destinationIata: String
}

nonisolated extension Flight {
    /// Builds a sample flight relative to a reference instant so previews always contain a
    /// "today" case regardless of when they are run.
    static func sample(
        id: String,
        route: SampleRoute,
        departingIn hours: TimeInterval,
        lasting duration: TimeInterval = 3,
        flightNumber: String? = "UA890",
        from reference: Date = .now
    ) -> Flight {
        let departure = reference.addingTimeInterval(hours * 3600)
        return Flight(
            id: id,
            tripNumber: "10000\(id.suffix(2))",
            flightNumber: flightNumber,
            tailNumber: "N987UA",
            origin: Airport(label: route.origin, iata: route.originIata),
            destination: Airport(label: route.destination, iata: route.destinationIata),
            departure: departure,
            arrival: departure.addingTimeInterval(duration * 3600),
            price: 12500
        )
    }

    /// A flight departing later today — the only case that earns the "Flight Today" badge.
    static var sampleToday: Flight {
        sample(id: "FL01", route: .newYorkToLondon, departingIn: 3)
    }

    /// A flight that has already departed, for the Past segment.
    static var samplePast: Flight {
        sample(id: "FL02", route: .vegasToNewYork, departingIn: -72)
    }

    /// Reproduces `FL006`, which the service returns with a null flight number.
    static var sampleMissingFlightNumber: Flight {
        sample(id: "FL06", route: .phoenixToPortland, departingIn: -120, flightNumber: nil)
    }

    /// Reproduces `FL034`, whose origin label is 72 characters long — a layout stress case.
    static var sampleLongName: Flight {
        sample(id: "FL34", route: .verboseNewYork, departingIn: 48)
    }

    /// A mixed set covering today, future, past, a null flight number and a long label.
    static var samples: [Flight] {
        [
            sampleToday,
            sample(id: "FL03", route: .denverToRome, departingIn: 26),
            sampleLongName,
            sample(id: "FL04", route: .chicagoToBerlin, departingIn: 120),
            samplePast,
            sampleMissingFlightNumber,
            sample(id: "FL05", route: .seattleToDallas, departingIn: -300, flightNumber: "UA124")
        ]
    }
}

nonisolated extension SampleRoute {
    static let newYorkToLondon = Self(
        origin: "New York (JFK)",
        originIata: "JFK",
        destination: "London (LHR)",
        destinationIata: "LHR"
    )

    static let vegasToNewYork = Self(
        origin: "Las Vegas (LAS)",
        originIata: "LAS",
        destination: "New York (JFK)",
        destinationIata: "JFK"
    )

    static let phoenixToPortland = Self(
        origin: "Phoenix (PHX)",
        originIata: "PHX",
        destination: "Portland (PDX)",
        destinationIata: "PDX"
    )

    static let denverToRome = Self(
        origin: "Denver (DEN)",
        originIata: "DEN",
        destination: "Rome (FCO)",
        destinationIata: "FCO"
    )

    static let chicagoToBerlin = Self(
        origin: "Chicago (ORD)",
        originIata: "ORD",
        destination: "Berlin (BER)",
        destinationIata: "BER"
    )

    static let seattleToDallas = Self(
        origin: "Seattle (SEA)",
        originIata: "SEA",
        destination: "Dallas (DFW)",
        destinationIata: "DFW"
    )

    /// `FL034`'s 72-character origin label, paired with a contradicting IATA code.
    static let verboseNewYork = Self(
        origin: "The Beautiful and Historic City of New York Where Dreams Come True (JFK)",
        originIata: "SFO",
        destination: "Seattle (SEA)",
        destinationIata: "SEA"
    )
}
#endif
