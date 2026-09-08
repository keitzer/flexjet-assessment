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
    }
}

#Preview("Placeholder") {
    PlaceholderScreen(
        title: "Favorites",
        systemImage: "heart",
        message: "Flights you save will appear here."
    )
}
