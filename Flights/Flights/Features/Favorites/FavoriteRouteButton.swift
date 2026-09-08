import SwiftUI

/// Used only on flight/route details; lists expose navigation, never favorite actions.
struct FavoriteRouteButton: View {
    let route: FavoriteRoute
    let store: FavoriteRoutesStore
    var source: AnalyticsPage = .routeDetails
    var context: AnalyticsContext?
    @Environment(\.analytics) private var analytics

    private var isFavorite: Bool { store.contains(route.id) }

    var body: some View {
        Button {
            analytics.button(.favoriteRoute, page: source, context: context ?? .route(route.id))
            Haptics.tap()
            store.toggle(route, source: source, context: context)
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .foregroundStyle(Theme.Palette.brand)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isFavorite ? "Remove Favorite Route" : "Favorite Route")
        .accessibilityValue(isFavorite ? "Favorited" : "Not favorited")
        .accessibilityHint("\(route.id.title). Saved routes appear in the Favorites tab.")
    }
}

#if DEBUG
#Preview {
    FavoriteRouteButton(route: FavoriteRoute(flight: .samplePast), store: AppDependencies.preview().favorites)
        .padding()
}
#endif
