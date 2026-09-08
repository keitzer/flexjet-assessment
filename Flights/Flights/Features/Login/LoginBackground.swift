import SwiftUI

struct LoginBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Theme.Login.heroStart, Theme.Login.heroEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .topTrailing) {
            Image(systemName: "globe.americas")
                .font(Theme.Typography.loginGlobe)
                .foregroundStyle(.white.opacity(Theme.Login.globeOpacity))
                .padding(.top, Theme.Spacing.xLarge)
                .accessibilityHidden(true)
        }
    }
}

#Preview {
    LoginBackground()
}
