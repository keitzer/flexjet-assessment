@testable import Flights
import Testing

@MainActor
@Suite("Login error and cancellation regressions")
struct LoginRegressionTests {
    @Test("Clearing a rejected password preserves the error until the user edits", arguments: [true, false])
    func failureSurvivesPasswordReset(editUsername: Bool) async {
        let session = SessionStore(storage: InMemoryTokenStorage())
        let model = LoginViewModel(apiClient: MockFlightsAPIClient.rejectingSignIn, session: session)
        model.username = "john"
        model.password = "wrong"
        await model.signIn()
        #expect(model.password.isEmpty)
        #expect(model.state == .failed(.invalidCredentials))
        if editUsername {
            model.username = "corrected"
        } else {
            model.password = "corrected"
        }
        #expect(model.state == .editing)
        #expect(model.errorMessage == nil)
    }

    @Test("Cancelled sign-in preserves the form and does not start a session")
    func cancelledSignIn() async {
        let session = SessionStore(storage: InMemoryTokenStorage())
        let model = LoginViewModel(apiClient: CancelledAPIClient(), session: session)
        model.username = "john"
        model.password = "12345"
        await model.signIn()
        #expect(model.state == .editing)
        #expect(model.password == "12345")
        #expect(!session.isSignedIn)
        #expect(model.canSubmit)
    }
}
