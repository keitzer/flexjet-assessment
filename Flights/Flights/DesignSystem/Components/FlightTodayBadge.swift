import SwiftUI

/// The "Flight Today" pill shown on an upcoming flight departing today.
///
/// Purely presentational — whether it appears is decided by `FlightClassifier`.
struct FlightTodayBadge: View {
    var body: some View {
        Label {
            Text("Flight Today")
        } icon: {
            Image(systemName: "calendar")
        }
        .font(Theme.Typography.emphasizedBody)
        .foregroundStyle(.white)
        .padding(.horizontal, Theme.Spacing.medium)
        .padding(.vertical, Theme.Spacing.small)
        .background(Theme.Palette.brand, in: .capsule)
        .accessibilityLabel("Departing today")
    }
}

#Preview("Flight today badge") {
    FlightTodayBadge().padding()
}
