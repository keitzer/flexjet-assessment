import Foundation
import Observation

/// Destinations reachable from the Flights tab.
///
/// A value type rather than a view, so navigation state stays inspectable and testable.
nonisolated enum FlightRoute: Hashable, Sendable {
    case detail(Flight)
    case favoriteRoute(FavoriteRoute)

    var analyticsPage: AnalyticsPage {
        switch self {
        case .detail: .flightDetails
        case .favoriteRoute: .routeDetails
        }
    }

    var analyticsContext: AnalyticsContext {
        switch self {
        case .detail(let flight): .flight(flight)
        case .favoriteRoute(let route): .route(route.id)
        }
    }
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
    var path: [FlightRoute] = [] {
        didSet {
            analytics.change(
                .navigationDepth,
                page: path.last?.analyticsPage ?? rootPage,
                from: .integer(oldValue.count),
                to: .integer(path.count),
                context: path.last?.analyticsContext ?? .empty
            )
        }
    }
    private let analytics: Analytics
    private let rootPage: AnalyticsPage

    init(analytics: Analytics = .disabled, rootPage: AnalyticsPage = .flights) {
        self.analytics = analytics
        self.rootPage = rootPage
    }

    func showDetail(_ flight: Flight) {
        path.append(.detail(flight))
    }

    func showRoute(_ route: FavoriteRoute) {
        path.append(.favoriteRoute(route))
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}
