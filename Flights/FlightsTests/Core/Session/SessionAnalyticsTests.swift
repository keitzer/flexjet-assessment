@testable import Flights
import Testing

@MainActor
struct SessionAnalyticsTests {
    @Test("Restoration and unchanged session status produce no duplicate events")
    func sessionTransitions() {
        let recorder = RecordingAnalyticsLogger()
        let session = SessionStore(
            storage: InMemoryTokenStorage(token: "secret"), analytics: Analytics(logger: recorder)
        )
        #expect(recorder.events.isEmpty)
        session.beginSession(token: "replacement")
        #expect(recorder.events.isEmpty)
        session.endSession()
        session.endSession()
        session.beginSession(token: "new-secret")
        #expect(recorder.events.map { $0.properties["value"] } == [.bool(false), .bool(true)])
        #expect(recorder.events.allSatisfy { $0.properties.count == 4 })
    }
}
