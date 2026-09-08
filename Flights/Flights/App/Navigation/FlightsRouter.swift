import Foundation
import Observation

/// Destinations reachable from the Flights tab.
///
/// A value type rather than a view, so navigation state stays inspectable and testable.
nonisolated enum FlightRoute: Hashable, Sendable {
    case detail(Flight)
}

/// Owns the Flights tab's navigation stack.
///
/// This is the coordinator role expressed the way SwiftUI wants it: a typed path that views push
/// onto, rather than an object that builds and presents view controllers. Screens call
/// `showDetail(_:)` instead of constructing their own `NavigationLink` destinations, so routing
/// lives in one place and can be driven from tests or a deep link.
@Observable
@MainActor
final class FlightsRouter {
    var path: [FlightRoute] = []

    func showDetail(_ flight: Flight) {
        path.append(.detail(flight))
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}
