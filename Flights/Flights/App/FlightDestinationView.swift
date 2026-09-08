import SwiftUI

/// Both tabs share destination construction while keeping independent navigation stacks.
struct FlightDestinationView: View {
    let route: FlightRoute
    let dependencies: AppDependencies

    var body: some View {
        switch route {
        case .detail(let flight):
            FlightDetailView(flight: flight, dependencies: dependencies)
        case .favoriteRoute(let favorite):
            FavoriteRouteDetailView(route: favorite, dependencies: dependencies)
        }
    }
}
