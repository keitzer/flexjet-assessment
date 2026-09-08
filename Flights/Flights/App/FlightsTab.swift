import SwiftUI

/// The Flights tab: a navigation stack driven by `FlightsRouter`.
///
/// The router owns the path and this view owns the destination mapping, so a route value is the
/// only thing a screen needs to navigate.
struct FlightsTab: View {
    let dependencies: AppDependencies

    @State private var router: FlightsRouter

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _router = State(wrappedValue: FlightsRouter(analytics: dependencies.analytics, rootPage: .flights))
    }

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            FlightListView(dependencies: dependencies)
                .navigationDestination(for: FlightRoute.self) { route in
                    FlightDestinationView(route: route, dependencies: dependencies)
                }
        }
        .environment(router)
    }
}

#if DEBUG
#Preview("Flights tab") {
    FlightsTab(dependencies: .preview())
}
#endif
