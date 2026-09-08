import Foundation

/// The two segments of the Flights screen.
nonisolated enum FlightCategory: String, CaseIterable, Identifiable, Sendable {
    case upcoming
    case past

    var id: String { rawValue }

    var title: String {
        switch self {
        case .upcoming: "Upcoming"
        case .past: "Past"
        }
    }
}
