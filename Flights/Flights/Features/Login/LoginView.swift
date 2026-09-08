import SwiftUI

/// The sign-in screen. No design was supplied, so this follows the same card, colour and
/// spacing tokens as the Flights screens.
struct LoginView: View {
    @State private var viewModel: LoginViewModel
    @State private var signInTask: Task<Void, Never>?
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case username
        case password
    }

    init(dependencies: AppDependencies) {
        _viewModel = State(
            wrappedValue: LoginViewModel(
                apiClient: dependencies.apiClient,
                session: dependencies.session
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xLarge) {
                header
                fields
                errorMessage
                submitButton
            }
            .padding(Theme.Spacing.xLarge)
            .frame(maxWidth: 480)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.Palette.screen)
        .scrollDismissesKeyboard(.interactively)
        .onDisappear { signInTask?.cancel() }
    }

    private var header: some View {
        VStack(spacing: Theme.Spacing.small) {
            Image(systemName: "airplane.departure")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(Theme.Palette.brand)
            Text("Flights")
                .font(.largeTitle.weight(.bold))
            Text("Sign in to see your itinerary.")
                .font(.subheadline)
                .foregroundStyle(Theme.Palette.secondaryText)
        }
        .padding(.top, Theme.Spacing.xLarge)
        .accessibilityElement(children: .combine)
    }

    private var fields: some View {
        @Bindable var viewModel = viewModel
        return VStack(spacing: Theme.Spacing.medium) {
            LabeledField(title: "Username") {
                TextField("Username", text: $viewModel.username)
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .username)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }
            }
            LabeledField(title: "Password") {
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.password)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.go)
                    .onSubmit { submit() }
            }
        }
    }

    @ViewBuilder
    private var errorMessage: some View {
        if let message = viewModel.errorMessage {
            Label(message, systemImage: "exclamationmark.circle.fill")
                .font(.footnote)
                .foregroundStyle(Theme.Palette.brand)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.opacity.combined(with: .move(edge: .top)))
                .accessibilityAddTraits(.isStaticText)
        }
    }

    private var submitButton: some View {
        Button(action: submit) {
            ZStack {
                // Keeps the button's height stable while the spinner replaces the label.
                Text("Sign In").opacity(viewModel.isSubmitting ? 0 : 1)
                if viewModel.isSubmitting {
                    ProgressView().tint(.white)
                }
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.medium)
        }
        .buttonStyle(.borderedProminent)
        .tint(Theme.Palette.brand)
        .disabled(!viewModel.canSubmit)
        .animation(.snappy, value: viewModel.isSubmitting)
    }

    private func submit() {
        guard signInTask == nil, viewModel.canSubmit else { return }
        Haptics.tap()
        focusedField = nil
        signInTask = Task {
            defer { signInTask = nil }
            await viewModel.signIn()
        }
    }
}

#if DEBUG
#Preview("Login") {
    LoginView(dependencies: .preview())
}

#Preview("Rejected credentials") {
    LoginView(dependencies: .preview(apiClient: MockFlightsAPIClient.rejectingSignIn))
}
#endif
