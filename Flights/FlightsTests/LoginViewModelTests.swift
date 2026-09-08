@testable import Flights
import Foundation
import Testing

@MainActor
@Suite("Login behaviour")
struct LoginViewModelTests {
    private func makeViewModel(client: FlightsAPIClient) -> (model: LoginViewModel, session: SessionStore) {
        let session = SessionStore(storage: InMemoryTokenStorage())
        return (LoginViewModel(apiClient: client, session: session), session)
    }

    @Test("Submission is blocked until both fields have content")
    func requiresBothFields() {
        let (model, _) = makeViewModel(client: MockFlightsAPIClient())
        #expect(!model.canSubmit)
        model.username = "john"
        #expect(!model.canSubmit)
        model.password = "12345"
        #expect(model.canSubmit)
    }

    @Test("Whitespace alone does not count as a username")
    func rejectsWhitespaceUsername() {
        let (model, _) = makeViewModel(client: MockFlightsAPIClient())
        model.username = "   "
        model.password = "12345"
        #expect(!model.canSubmit)
    }

    @Test("A successful sign-in starts the session")
    func successStartsSession() async {
        let (model, session) = makeViewModel(client: MockFlightsAPIClient(signInResult: .success("jwt")))
        model.username = "john"
        model.password = "12345"
        await model.signIn()
        #expect(session.token == "jwt")
        #expect(session.isSignedIn)
    }

    @Test("Rejected credentials surface a message, clear the password and leave the user signed out")
    func failureKeepsUserSignedOut() async {
        let (model, session) = makeViewModel(client: MockFlightsAPIClient.rejectingSignIn)
        model.username = "john"
        model.password = "wrong"
        await model.signIn()
        #expect(!session.isSignedIn)
        #expect(model.state == .failed(.invalidCredentials))
        #expect(model.errorMessage != nil)
        // The password is cleared so a failed attempt cannot be resubmitted unchanged.
        #expect(model.password.isEmpty)
    }

    @Test("Editing a field clears a previous failure")
    func editingClearsError() async {
        let (model, _) = makeViewModel(client: MockFlightsAPIClient.rejectingSignIn)
        model.username = "john"
        model.password = "wrong"
        await model.signIn()
        #expect(model.errorMessage != nil)
        model.clearErrorIfNeeded()
        #expect(model.state == .editing)
        #expect(model.errorMessage == nil)
    }

    @Test("Submitting with an incomplete form does nothing")
    func ignoresIncompleteSubmission() async {
        let (model, session) = makeViewModel(client: MockFlightsAPIClient())
        await model.signIn()
        #expect(model.state == .editing)
        #expect(!session.isSignedIn)
    }
}

@MainActor
@Suite("Completion state")
struct FlightCompletionStoreTests {
    @Test("Marking a flight complete persists through the storage layer")
    func persistsCompletion() {
        let storage = InMemoryCompletionStorage()
        let store = FlightCompletionStore(storage: storage)
        #expect(!store.isComplete("FL001"))

        store.setComplete(true, for: "FL001")
        #expect(store.isComplete("FL001"))
        #expect(storage.loadCompletedIDs() == ["FL001"])

        // A new store over the same storage sees the saved value.
        #expect(FlightCompletionStore(storage: storage).isComplete("FL001"))
    }

    @Test("Toggling reverses the current state")
    func togglesCompletion() {
        let store = FlightCompletionStore(storage: InMemoryCompletionStorage())
        store.toggle("FL001")
        #expect(store.isComplete("FL001"))
        store.toggle("FL001")
        #expect(!store.isComplete("FL001"))
    }

    @Test("Completing one flight leaves others untouched")
    func isolatesFlights() {
        let store = FlightCompletionStore(storage: InMemoryCompletionStorage(ids: ["FL001"]))
        store.setComplete(true, for: "FL002")
        #expect(store.completedIDs == ["FL001", "FL002"])
    }
}

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
