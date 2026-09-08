import SwiftUI

/// The Flights tab: a navigation stack driven by `FlightsRouter`.
///
/// The router owns the path and this view owns the destination mapping, so a route value is the
/// only thing a screen needs to navigate.
struct FlightsTab: View {
    let dependencies: AppDependencies

    @State private var router = FlightsRouter()

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            FlightListView(dependencies: dependencies)
                .navigationDestination(for: FlightRoute.self) { route in
                    destination(for: route)
                }
        }
        .environment(router)
    }

    @ViewBuilder
    private func destination(for route: FlightRoute) -> some View {
        switch route {
        case .detail(let flight):
            FlightDetailView(flight: flight, dependencies: dependencies)
        }
    }
}

#Preview("Flights tab") {
    FlightsTab(dependencies: .preview())
}
