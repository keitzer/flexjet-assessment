import SwiftUI

struct FavoritesTab: View {
    let dependencies: AppDependencies
    @State private var router: FlightsRouter

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _router = State(wrappedValue: FlightsRouter(analytics: dependencies.analytics, rootPage: .favorites))
    }

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            FavoritesListView(store: dependencies.favorites)
                .navigationDestination(for: FlightRoute.self) { route in
                    FlightDestinationView(route: route, dependencies: dependencies)
                }
        }
        .environment(router)
    }
}

#if DEBUG
#Preview("Favorites") {
    FavoritesTab(dependencies: .preview(favoriteRoutes: [FavoriteRoute(flight: .samplePast)]))
}
#endif
