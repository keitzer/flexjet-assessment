import Foundation
import Observation

/// Drives the login screen.
///
/// Credential checking is the service's job, not the app's — the only local validation is that
/// both fields are non-empty, so the app never invents its own idea of a valid user.
@Observable
@MainActor
final class LoginViewModel {
    enum ViewState: Equatable {
        case editing
        case submitting
        case failed(APIError)
    }

    var username = ""
    var password = ""
    private(set) var state: ViewState = .editing

    private let apiClient: FlightsAPIClient
    private let session: SessionStore

    init(apiClient: FlightsAPIClient, session: SessionStore) {
        self.apiClient = apiClient
        self.session = session
    }

    var isSubmitting: Bool {
        state == .submitting
    }

    var canSubmit: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty
            && !password.isEmpty
            && !isSubmitting
    }

    var errorMessage: String? {
        guard case .failed(let error) = state else { return nil }
        return error.localizedDescription
    }

    func signIn() async {
        guard canSubmit else { return }
        state = .submitting
        do {
            let token = try await apiClient.signIn(
                username: username.trimmingCharacters(in: .whitespaces),
                password: password
            )
            // Publishing the token flips the root view over to the main tabs.
            session.beginSession(token: token)
        } catch {
            state = .failed(.from(error))
            password = ""
        }
    }

    /// Clears a previous failure once the user edits either field.
    func clearErrorIfNeeded() {
        if case .failed = state {
            state = .editing
        }
    }
}
