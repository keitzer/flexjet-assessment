import Observation

@Observable
@MainActor
final class FavoriteRoutesStore {
    private var saved: [RouteIdentity: FavoriteRoute]
    private let storage: FavoriteRoutesPersisting

    init(storage: FavoriteRoutesPersisting) {
        self.storage = storage
        saved = Dictionary(storage.load().map { ($0.id, $0) }) { first, _ in first }
    }

    var routes: [FavoriteRoute] {
        saved.values.sorted { $0.id.title < $1.id.title }
    }

    func contains(_ route: RouteIdentity) -> Bool {
        saved[route] != nil
    }

    func toggle(_ route: FavoriteRoute) {
        if contains(route.id) {
            saved.removeValue(forKey: route.id)
        } else {
            saved[route.id] = route
        }
        storage.save(routes)
    }
}
