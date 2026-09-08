import SwiftUI

struct FavoriteRouteDetailView: View {
    let route: FavoriteRoute
    private let favorites: FavoriteRoutesStore
    @State private var viewModel: FlightListViewModel

    init(route: FavoriteRoute, dependencies: AppDependencies) {
        self.route = route
        favorites = dependencies.favorites
        _viewModel = State(wrappedValue: FlightListViewModel(
            apiClient: dependencies.apiClient,
            session: dependencies.session,
            completion: dependencies.completion,
            routeFilter: route.id,
            cache: dependencies.flightsCache
        ))
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: Theme.Spacing.large) {
            VStack(spacing: Theme.Spacing.large) {
                HStack(alignment: .top, spacing: Theme.Spacing.medium) {
                    EndpointCard(location: route.originLabel, caption: "Origin")
                    EndpointCard(location: route.destinationLabel, caption: "Destination")
                }
                SegmentedFilterControl(
                    items: FlightCategory.allCases,
                    title: \.title,
                    selection: $viewModel.selectedCategory
                )
            }
            .padding(.horizontal, Theme.Spacing.large)
            FlightResultsView(viewModel: viewModel)
        }
        .padding(.top, Theme.Spacing.large)
        .background(Theme.Palette.screen)
        .navigationTitle(route.id.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FavoriteRouteButton(route: route, store: favorites)
            }
        }
        .task { await viewModel.loadIfNeeded() }
        .refreshable { await viewModel.load() }
        .refreshFlightTime(departures: viewModel.flights.map(\.departure), refresh: viewModel.refreshTime)
    }
}

#if DEBUG
#Preview("Route details") {
    NavigationStack {
        FavoriteRouteDetailView(route: FavoriteRoute(flight: .samplePast), dependencies: .preview())
    }
    .environment(FlightsRouter())
}
#endif
