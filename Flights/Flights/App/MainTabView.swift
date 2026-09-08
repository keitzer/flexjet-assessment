import SwiftUI

/// The signed-in shell: the four tabs from the design.
struct MainTabView: View {
    let dependencies: AppDependencies
    @Environment(\.analytics) private var analytics
    @State private var selectedTab: AppTab = .flights

    private enum AppTab: String, Hashable {
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
                FavoritesTab(dependencies: dependencies)
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
        .onChange(of: selectedTab) { oldValue, newValue in
            analytics.button(
                .selectTab,
                page: .app,
                context: AnalyticsContext(properties: ["tab": .string(newValue.rawValue)])
            )
            analytics.change(.tab, page: .app, from: .string(oldValue.rawValue), to: .string(newValue.rawValue))
            Haptics.tap()
        }
    }
}

#if DEBUG
#Preview("Main tabs") {
    MainTabView(dependencies: .preview())
        .environment(\.dependencies, .preview())
}
#endif
