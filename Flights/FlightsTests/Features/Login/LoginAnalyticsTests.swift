@testable import Flights
import Foundation
import Testing

@MainActor
struct LoginAnalyticsTests {
    @Test("Sign-in outcomes report state without entered credentials or returned token", arguments: [true, false])
    func outcomes(succeeds: Bool) async throws {
        let recorder = RecordingAnalyticsLogger()
        let client = MockFlightsAPIClient(
            signInResult: succeeds ? .success("private-token") : .failure(.invalidCredentials)
        )
        let model = LoginViewModel(
            apiClient: client,
            session: SessionStore(storage: InMemoryTokenStorage()),
            analytics: Analytics(logger: recorder)
        )
        await model.signIn()
        #expect(recorder.events.isEmpty)
        model.username = "private-username"
        model.password = "private-password"
        await model.signIn()
        #expect(recorder.events.map { $0.properties["value"] } == [
            .string("submitting"), .string(succeeds ? "signed_in" : "failed_invalid_credentials")
        ])
        let encoded = try #require(String(data: JSONEncoder().encode(recorder.events), encoding: .utf8))
        #expect(!encoded.contains("private-"))
    }
    @Test("Late canceled or superseded responses never report authentication success", arguments: [true, false])
    func obsoleteOutcomes(cancel: Bool) async {
        let recorder = RecordingAnalyticsLogger()
        let client = ControlledSignInAPIClient()
        let session = SessionStore(storage: InMemoryTokenStorage())
        let model = LoginViewModel(apiClient: client, session: session, analytics: Analytics(logger: recorder))
        model.username = "private-user"
        model.password = "private-password"
        let request = Task { await model.signIn() }
        await client.waitForRequest()
        if cancel {
            request.cancel()
        } else {
            session.beginSession(token: "newer-token")
        }
        await client.finish(succeeds: true)
        await request.value
        #expect(recorder.events.map { $0.properties["value"] } == [.string("submitting"), .string("editing")])
    }
}
