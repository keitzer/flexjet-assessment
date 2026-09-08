import SwiftUI

/// Chooses between the login screen and the signed-in tabs.
///
/// The single place that reacts to authentication state: because `SessionStore` is observable,
/// a sign-out anywhere in the app — including one triggered by a 401 — returns the user here.
struct RootView: View {
    let dependencies: AppDependencies

    var body: some View {
        Group {
            if dependencies.session.isSignedIn {
                MainTabView(dependencies: dependencies)
                    // Identity keyed on sign-in state so the tabs are rebuilt with fresh view
                    // models for a new session rather than reusing the previous user's.
                    .id("signedIn")
            } else {
                LoginView(dependencies: dependencies)
                    .id("signedOut")
            }
        }
        .animation(.snappy(duration: 0.3), value: dependencies.session.isSignedIn)
        .transition(.opacity)
        .environment(\.dependencies, dependencies)
    }
}

#Preview("Signed out") {
    RootView(
        dependencies: AppDependencies(
            apiClient: MockFlightsAPIClient(),
            session: SessionStore(storage: InMemoryTokenStorage()),
            completion: FlightCompletionStore(storage: InMemoryCompletionStorage())
        )
    )
}

#Preview("Signed in") {
    RootView(dependencies: .preview())
}
