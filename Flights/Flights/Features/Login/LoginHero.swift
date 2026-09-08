import SwiftUI

/// A self-contained aviation header, built from native symbols and adaptive text.
struct LoginHero: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xLarge) {
            HStack(spacing: Theme.Spacing.small) {
                Image(systemName: "airplane")
                Text("FLIGHTS")
                    .tracking(Theme.Login.brandTracking)
            }
            .font(Theme.Typography.emphasizedBody)
            VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                Text("Your journey,\nin one place.")
                    .font(Theme.Typography.screenTitle)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                Text("From takeoff to touchdown,\nkeep every flight close.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.white.opacity(Theme.Login.subtitleOpacity))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Login hero") {
    LoginHero().padding()
}
