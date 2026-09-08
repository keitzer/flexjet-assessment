@testable import Flights
import Foundation
import Testing

@Suite("Keychain token storage", .serialized)
struct KeychainTokenStorageTests {
    @Test("Tokens survive reopening, are replaced on login, and removed on logout")
    func roundTrip() {
        let service = "FlightsTests.\(UUID().uuidString)"
        let storage = KeychainTokenStorage(service: service)
        defer { storage.clear() }
        #expect(storage.load() == nil)
        storage.save("first-test-token")
        #expect(KeychainTokenStorage(service: service).load() == "first-test-token")
        storage.save("replacement-test-token")
        #expect(storage.load() == "replacement-test-token")
        storage.clear()
        #expect(KeychainTokenStorage(service: service).load() == nil)
    }
}
