import SwiftUI

/// The app's dependency container.
///
/// Passed down through the environment so any screen can be built with real services in the app
/// and stubs in a preview or test, without any type reaching for a singleton.
@MainActor
struct AppDependencies {
    let apiClient: FlightsAPIClient
    let session: SessionStore
    let completion: FlightCompletionStore
    let favorites: FavoriteRoutesStore
    let flightsCache: FlightsCache
    let analytics: Analytics

    /// The configuration the shipping app runs with.
    ///
    /// In Debug builds only, launching with `-seedToken <jwt>` starts the app already signed in
    /// against the real service. That is a QA and demo affordance — it lets the signed-in screens
    /// be inspected without typing credentials on a simulator keyboard — and it compiles out of
    /// Release entirely.
    static func live() -> Self {
        let analytics = Analytics(logger: ConsoleAnalyticsLogger())
        return Self(
            apiClient: LiveFlightsAPIClient(),
            session: SessionStore(storage: launchStorage(), analytics: analytics),
            completion: FlightCompletionStore(),
            favorites: FavoriteRoutesStore(storage: UserDefaultsFavoriteRoutesStorage(), analytics: analytics),
            flightsCache: FlightsCache(),
            analytics: analytics
        )
    }

    private static func launchStorage() -> TokenStorage {
        #if DEBUG
        if let seeded = UserDefaults.standard.string(forKey: "seedToken"), !seeded.isEmpty {
            return InMemoryTokenStorage(token: seeded)
        }
        #endif
        return KeychainTokenStorage()
    }

    #if DEBUG
    /// A signed-in container backed by stub data, for previews.
    static func preview(
        apiClient: FlightsAPIClient = MockFlightsAPIClient(),
        completedIDs: Set<String> = [],
        favoriteRoutes: [FavoriteRoute] = []
    ) -> Self {
        Self(
            apiClient: apiClient,
            session: SessionStore(storage: InMemoryTokenStorage(token: "preview-token")),
            completion: FlightCompletionStore(storage: InMemoryCompletionStorage(ids: completedIDs)),
            favorites: FavoriteRoutesStore(storage: InMemoryFavoriteRoutesStorage(routes: favoriteRoutes)),
            flightsCache: FlightsCache(),
            analytics: .disabled
        )
    }
    #endif
}

extension EnvironmentValues {
    /// Defaults to the live container so a view is never left without dependencies.
    @Entry var dependencies: AppDependencies = .live()
}
