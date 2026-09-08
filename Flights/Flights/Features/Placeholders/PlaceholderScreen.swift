import SwiftUI

/// Stands in for a tab that the brief does not specify.
///
/// Present so the tab bar matches the design and the navigation shell is complete, and honest
/// about being unbuilt rather than faking content.
struct PlaceholderScreen: View {
    let title: String
    let systemImage: String
    let message: String

    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label(title, systemImage: systemImage)
            } description: {
                Text(message)
            }
            .navigationTitle(title)
        }
        .analyticsPage(.contracts)
    }
}

#Preview("Placeholder") {
    PlaceholderScreen(
        title: "Contracts",
        systemImage: "signature",
        message: "Your signed contracts will appear here."
    )
}
