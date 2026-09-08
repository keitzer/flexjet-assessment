@testable import Flights
import Testing

@MainActor
@Suite("Session lifecycle")
struct SessionStoreTests {
    @Test("A stored token is restored on launch")
    func restoresToken() {
        #expect(SessionStore(storage: InMemoryTokenStorage(token: "saved")).isSignedIn)
        #expect(!SessionStore(storage: InMemoryTokenStorage()).isSignedIn)
    }

    @Test("Ending a session clears the stored token")
    func clearsToken() {
        let storage = InMemoryTokenStorage(token: "saved")
        let session = SessionStore(storage: storage)
        session.endSession()
        #expect(!session.isSignedIn)
        #expect(storage.load() == nil)
    }
}
