import Foundation

@MainActor
protocol FavoriteRoutesPersisting {
    func load() -> [FavoriteRoute]
    func save(_ routes: [FavoriteRoute])
}

/// Favorites are non-sensitive, device-local preferences, like flight completion.
@MainActor
struct UserDefaultsFavoriteRoutesStorage: FavoriteRoutesPersisting {
    private let defaults: UserDefaults
    static let key = "favoriteRoutes.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> [FavoriteRoute] {
        guard let data = defaults.data(forKey: Self.key) else { return [] }
        return (try? JSONDecoder().decode([FavoriteRoute].self, from: data)) ?? []
    }

    func save(_ routes: [FavoriteRoute]) {
        defaults.set(try? JSONEncoder().encode(routes), forKey: Self.key)
    }
}

@MainActor
final class InMemoryFavoriteRoutesStorage: FavoriteRoutesPersisting {
    private var routes: [FavoriteRoute]

    init(routes: [FavoriteRoute] = []) {
        self.routes = routes
    }

    func load() -> [FavoriteRoute] { routes }
    func save(_ routes: [FavoriteRoute]) { self.routes = routes }
}
