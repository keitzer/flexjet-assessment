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

        var analyticsName: String {
            switch self {
            case .editing: "editing"
            case .submitting: "submitting"
            case .failed(let error): "failed_\(error.analyticsCode)"
            }
        }
    }

    var username = "" {
        didSet { clearErrorIfNeeded() }
    }
    var password = "" {
        didSet { clearErrorIfNeeded() }
    }
    private(set) var state: ViewState = .editing {
        didSet {
            analytics.change(
                .authentication,
                page: .login,
                from: .string(oldValue.analyticsName),
                to: .string(state.analyticsName)
            )
        }
    }

    private let apiClient: FlightsAPIClient
    private let session: SessionStore
    private let analytics: Analytics

    init(apiClient: FlightsAPIClient, session: SessionStore, analytics: Analytics = .disabled) {
        self.analytics = analytics
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
        let sessionRevision = session.revision
        state = .submitting
        do {
            try Task.checkCancellation()
            let token = try await apiClient.signIn(
                username: username.trimmingCharacters(in: .whitespaces),
                password: password
            )
            try Task.checkCancellation()
            guard session.revision == sessionRevision else {
                state = .editing
                return
            }
            // Publishing the token flips the root view over to the main tabs.
            analytics.change(
                .authentication,
                page: .login,
                from: .string("submitting"),
                to: .string("signed_in")
            )
            session.beginSession(token: token)
        } catch {
            guard session.revision == sessionRevision, !Task.isCancelled, !(error is CancellationError) else {
                state = .editing
                return
            }
            password = ""
            state = .failed(.from(error))
        }
    }

    /// Clears a previous failure once the user edits either field.
    private func clearErrorIfNeeded() {
        if case .failed = state {
            state = .editing
        }
    }
}
