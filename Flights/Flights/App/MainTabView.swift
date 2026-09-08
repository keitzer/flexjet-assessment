import SwiftUI

/// The signed-in shell: the four tabs from the design.
struct MainTabView: View {
    let dependencies: AppDependencies

    var body: some View {
        TabView {
            Tab("Flights", systemImage: "airplane") {
                FlightsTab(dependencies: dependencies)
            }
            Tab("Favorites", systemImage: "heart") {
                PlaceholderScreen(
                    title: "Favorites",
                    systemImage: "heart",
                    message: "Flights you save will appear here."
                )
            }
            Tab("Contracts", systemImage: "signature") {
                PlaceholderScreen(
                    title: "Contracts",
                    systemImage: "signature",
                    message: "Your signed contracts will appear here."
                )
            }
            Tab("Profile", systemImage: "person") {
                ProfileScreen()
            }
        }
        .tint(Theme.Palette.brand)
    }
}

#if DEBUG
#Preview("Main tabs") {
    MainTabView(dependencies: .preview())
        .environment(\.dependencies, .preview())
}
#endif
