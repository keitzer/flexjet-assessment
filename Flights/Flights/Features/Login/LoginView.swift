import SwiftUI

/// The sign-in screen. No design was supplied, so this follows the same card, colour and
/// spacing tokens as the Flights screens.
struct LoginView: View {
    @Environment(\.analytics) private var analytics
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
                session: dependencies.session,
                analytics: dependencies.analytics
            )
        )
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: Theme.Spacing.xLarge) {
                        LoginHero()
                            .onTapGesture { focusedField = nil }
                        form
                    }
                    .padding(Theme.Spacing.xLarge)
                    .frame(maxWidth: Theme.Size.loginFormMaxWidth)
                    .frame(maxWidth: .infinity)
                }
                .background {
                    Color.clear
                        .contentShape(.rect)
                        .onTapGesture { focusedField = nil }
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: focusedField) { _, field in
                    guard field != nil else { return }
                    withAnimation { proxy.scrollTo("loginFields", anchor: .top) }
                }
                .onChange(of: geometry.size.height) { _, _ in
                    guard focusedField != nil else { return }
                    withAnimation { proxy.scrollTo("loginFields", anchor: .top) }
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            submitButton
                .padding(Theme.Spacing.large)
                .frame(maxWidth: Theme.Size.loginFormMaxWidth)
                .frame(maxWidth: .infinity)
        }
        .background { LoginBackground().ignoresSafeArea() }
        .onDisappear { signInTask?.cancel() }
        .analyticsPage(.login)
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xLarge) {
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                Text("Welcome aboard")
                    .font(Theme.Typography.formTitle)
                    .foregroundStyle(Theme.Palette.primaryText)
                    .accessibilityAddTraits(.isHeader)
                Text("Sign in to view your flights.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Palette.secondaryText)
            }
            fields
                .id("loginFields")
            errorMessage
        }
        .padding(Theme.Spacing.xLarge)
        .background {
            RoundedRectangle(cornerRadius: Theme.Login.cornerRadius)
                .fill(Theme.Palette.card)
                .onTapGesture { focusedField = nil }
                .shadow(
                    color: .black.opacity(Theme.Login.shadowOpacity),
                    radius: Theme.Login.shadowRadius,
                    y: Theme.Login.shadowOffset
                )
        }
    }

    private var fields: some View {
        @Bindable var viewModel = viewModel
        return VStack(spacing: Theme.Spacing.medium) {
            LabeledField(title: "Username", symbol: "person", isFocused: focusedField == .username) {
                TextField("Username", text: $viewModel.username)
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .username)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }
            }
            LabeledField(title: "Password", symbol: "lock", isFocused: focusedField == .password) {
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
                .font(Theme.Typography.caption)
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
                HStack {
                    Text("Sign In")
                    Spacer()
                    Image(systemName: "arrow.right")
                        .accessibilityHidden(true)
                }
                .opacity(viewModel.isSubmitting ? 0 : 1)
                if viewModel.isSubmitting {
                    ProgressView().tint(.white)
                }
            }
            .font(Theme.Typography.primaryButton)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Theme.Spacing.xLarge)
            .padding(.vertical, Theme.Spacing.large)
            .foregroundStyle(.white)
            .background(Theme.Palette.brand, in: .rect(cornerRadius: Theme.Radius.card))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .strokeBorder(.white, lineWidth: Theme.Login.buttonBorderWidth)
            }
        }
        .buttonStyle(.plain)
        .opacity(viewModel.canSubmit ? 1 : Theme.Login.disabledOpacity)
        .disabled(!viewModel.canSubmit)
        .accessibilityLabel(viewModel.isSubmitting ? "Signing in" : "Sign In")
        .animation(.snappy, value: viewModel.isSubmitting)
    }

    private func submit() {
        guard signInTask == nil, viewModel.canSubmit else { return }
        analytics.button(.signIn, page: .login)
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

#Preview("Login — dark") {
    LoginView(dependencies: .preview())
        .preferredColorScheme(.dark)
}

#Preview("Rejected credentials") {
    LoginView(dependencies: .preview(apiClient: MockFlightsAPIClient.rejectingSignIn))
}
#endif
