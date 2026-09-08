import SwiftUI

/// One of the two origin/destination cards at the top of the detail screen.
struct EndpointCard: View {
    let location: String
    let caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
            Text(location)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.Palette.primaryText)
                // The service ships a 72-character label; wrap instead of truncating so the
                // full location stays readable.
                .lineLimit(3)
            Text(caption)
                .font(.footnote)
                .foregroundStyle(Theme.Palette.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.medium)
        .flightCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(caption): \(location)")
    }
}

#Preview("Endpoint cards") {
    HStack(alignment: .top, spacing: Theme.Spacing.medium) {
        EndpointCard(location: "Las Vegas (LAS)", caption: "Origin")
        EndpointCard(location: "New York (JFK)", caption: "Destination")
    }
    .padding()
    .background(Theme.Palette.screen)
}

#Preview("Long label") {
    HStack(alignment: .top, spacing: Theme.Spacing.medium) {
        EndpointCard(
            location: "The Beautiful and Historic City of New York Where Dreams Come True (JFK)",
            caption: "Origin"
        )
        EndpointCard(location: "Seattle (SEA)", caption: "Destination")
    }
    .padding()
    .background(Theme.Palette.screen)
}
