@testable import Flights
import Testing

@MainActor
@Suite("Sign-in task lifecycle")
struct SignInLifecycleTests {
    private func model(client: FlightsAPIClient, session: SessionStore) -> LoginViewModel {
        let model = LoginViewModel(apiClient: client, session: session)
        model.username = "john"
        model.password = "12345"
        return model
    }

    @Test("Cancelled sign-in ignores late responses", arguments: [true, false])
    func cancellationIgnoresResponse(succeeds: Bool) async {
        let client = ControlledSignInAPIClient()
        let session = SessionStore(storage: InMemoryTokenStorage())
        let model = model(client: client, session: session)
        let request = Task { await model.signIn() }
        await client.waitForRequest()
        #expect(model.isSubmitting)
        request.cancel()
        await client.finish(succeeds: succeeds)
        await request.value
        #expect(!session.isSignedIn)
        #expect(model.state == .editing)
        #expect(model.password == "12345")
    }

    @Test("An obsolete sign-in cannot replace a newer session", arguments: [true, false])
    func sessionChangeInvalidatesResponse(succeeds: Bool) async {
        let client = ControlledSignInAPIClient()
        let session = SessionStore(storage: InMemoryTokenStorage())
        let model = model(client: client, session: session)
        let request = Task { await model.signIn() }
        await client.waitForRequest()
        session.beginSession(token: "current-token")
        await client.finish(succeeds: succeeds)
        await request.value
        #expect(session.token == "current-token")
        #expect(model.state == .editing)
        #expect(model.password == "12345")
    }

    @Test("Signing out while authentication is pending invalidates its result")
    func signOutInvalidatesResponse() async {
        let client = ControlledSignInAPIClient()
        let session = SessionStore(storage: InMemoryTokenStorage())
        let model = model(client: client, session: session)
        let request = Task { await model.signIn() }
        await client.waitForRequest()
        session.endSession()
        await client.finish(succeeds: true)
        await request.value
        #expect(!session.isSignedIn)
        #expect(model.state == .editing)
    }

    @Test("A second submission while awaiting the service is ignored")
    func preventsDuplicateRequest() async {
        let client = ControlledSignInAPIClient()
        let session = SessionStore(storage: InMemoryTokenStorage())
        let model = model(client: client, session: session)
        let request = Task { await model.signIn() }
        await client.waitForRequest()
        await model.signIn()
        #expect(await client.callCount == 1)
        await client.finish(succeeds: true)
        await request.value
        #expect(session.token == "late-token")
    }
}
