import SwiftUI

/// Placeholder geometry rather than fabricated flight data, shown only during initial loading.
struct FlightListSkeleton: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.medium) {
                ForEach(0..<5) { _ in
                    row
                }
            }
            .padding(.horizontal, Theme.Spacing.large)
            .padding(.bottom, Theme.Spacing.large)
        }
        .scrollDisabled(true)
        .allowsHitTesting(false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Loading flights")
    }

    private var row: some View {
        HStack(spacing: Theme.Spacing.medium) {
            RoundedRectangle(cornerRadius: Theme.Radius.chip)
                .frame(width: Theme.Size.dateChip, height: Theme.Size.dateChip)
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                Capsule()
                    .frame(height: 14)
                Capsule()
                    .frame(maxWidth: 140)
                    .frame(height: 12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.trailing, Theme.Spacing.xLarge)
        }
        .foregroundStyle(Theme.Palette.skeleton)
        .modifier(Shimmer())
        .padding(Theme.Spacing.large)
        .flightCard()
    }
}

#Preview("Loading flights — dark") {
    FlightListSkeleton()
        .background(Theme.Palette.screen)
        .preferredColorScheme(.dark)
}

#Preview("Loading flights — light") {
    FlightListSkeleton()
        .preferredColorScheme(.light)
}
