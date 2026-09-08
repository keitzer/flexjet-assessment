import SwiftUI

/// Placeholder geometry rather than fabricated flight data, shown only during initial loading.
struct FlightListSkeleton: View {
    private enum Layout {
        static let rowCount = 5
        static let titleHeight: CGFloat = 14
        static let subtitleHeight: CGFloat = 12
        static let subtitleMaxWidth: CGFloat = 140
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.medium) {
                ForEach(0..<Layout.rowCount, id: \.self) { _ in
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
                    .frame(height: Layout.titleHeight)
                Capsule()
                    .frame(maxWidth: Layout.subtitleMaxWidth)
                    .frame(height: Layout.subtitleHeight)
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
