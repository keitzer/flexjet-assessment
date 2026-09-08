@testable import Flights
import Foundation
import Testing

@MainActor
@Suite("Favorite route state and persistence")
struct FavoriteRoutesStoreTests {
    @Test("Favoriting on one flight applies to another; removing from either reverses it")
    func sharedFavorite() {
        let storage = InMemoryFavoriteRoutesStorage()
        let store = FavoriteRoutesStore(storage: storage)
        let first = FavoriteRoute(flight: RouteFixtures.flight(id: "first"))
        let second = FavoriteRoute(flight: RouteFixtures.flight(id: "second", label: "Different label"))
        #expect(store.routes.isEmpty)
        store.toggle(first)
        #expect(store.contains(second.id))
        #expect(store.routes == [first])
        #expect(FavoriteRoutesStore(storage: storage).routes == [first])
        store.toggle(second)
        #expect(!store.contains(first.id))
        #expect(FavoriteRoutesStore(storage: storage).routes.isEmpty)
    }

    @Test("Restoring deduplicates route identity and sorts consistently")
    func deduplicatesAndSorts() {
        let first = FavoriteRoute(flight: RouteFixtures.flight())
        let duplicate = FavoriteRoute(flight: RouteFixtures.flight(label: "Other label"))
        let reverse = FavoriteRoute(flight: RouteFixtures.flight(origin: "SEA", destination: "SFO"))
        let store = FavoriteRoutesStore(storage: InMemoryFavoriteRoutesStorage(routes: [first, duplicate, reverse]))
        #expect(store.routes == [reverse, first])
        store.toggle(first)
        #expect(store.routes == [reverse])
    }

    @Test("UserDefaults persists routes across reopening and tolerates corrupt saved data")
    func persistedRoundTrip() throws {
        let suite = "FavoriteRoutesTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = UserDefaultsFavoriteRoutesStorage(defaults: defaults)
        #expect(storage.load().isEmpty)
        let route = FavoriteRoute(flight: RouteFixtures.flight())
        let store = FavoriteRoutesStore(storage: storage)
        store.toggle(route)
        let reopened = FavoriteRoutesStore(storage: UserDefaultsFavoriteRoutesStorage(defaults: defaults))
        #expect(reopened.routes == [route])
        reopened.toggle(route)
        #expect(storage.load().isEmpty)
        defaults.set(Data("invalid".utf8), forKey: UserDefaultsFavoriteRoutesStorage.key)
        #expect(storage.load().isEmpty)
    }
}
