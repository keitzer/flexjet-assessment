import SwiftUI

/// The signed-in shell: the four tabs from the design.
struct MainTabView: View {
    let dependencies: AppDependencies
    @State private var selectedTab: AppTab = .flights

    private enum AppTab: Hashable {
        case flights
        case favorites
        case contracts
        case profile
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Flights", systemImage: "airplane", value: AppTab.flights) {
                FlightsTab(dependencies: dependencies)
            }
            Tab("Favorites", systemImage: "heart", value: AppTab.favorites) {
                PlaceholderScreen(
                    title: "Favorites",
                    systemImage: "heart",
                    message: "Flights you save will appear here."
                )
            }
            Tab("Contracts", systemImage: "signature", value: AppTab.contracts) {
                PlaceholderScreen(
                    title: "Contracts",
                    systemImage: "signature",
                    message: "Your signed contracts will appear here."
                )
            }
            Tab("Profile", systemImage: "person", value: AppTab.profile) {
                ProfileScreen()
            }
        }
        .tint(Theme.Palette.brand)
        .sensoryFeedback(.selection, trigger: selectedTab)
    }
}

#if DEBUG
#Preview("Main tabs") {
    MainTabView(dependencies: .preview())
        .environment(\.dependencies, .preview())
}
#endif
