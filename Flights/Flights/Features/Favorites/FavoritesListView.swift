import SwiftUI

struct FavoritesListView: View {
    let store: FavoriteRoutesStore
    @Environment(FlightsRouter.self) private var router

    var body: some View {
        Group {
            if store.routes.isEmpty {
                ContentUnavailableView {
                    Label("Your favorite routes", systemImage: "heart")
                } description: {
                    Text("Open a flight's details and tap Favorite Route to save the journeys you take most.")
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: Theme.Spacing.medium) {
                        ForEach(store.routes) { route in
                            Button {
                                Haptics.tap()
                                router.showRoute(route)
                            } label: {
                                row(route)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(Theme.Spacing.large)
                }
            }
        }
        .background(Theme.Palette.screen)
        .navigationTitle("Favorites")
    }

    private func row(_ route: FavoriteRoute) -> some View {
        HStack(spacing: Theme.Spacing.large) {
            Image(systemName: "airplane")
                .foregroundStyle(Theme.Palette.brand)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                Text(route.id.title)
                    .font(Theme.Typography.primaryButton)
                    .foregroundStyle(Theme.Palette.primaryText)
                Text("\(route.originLabel) → \(route.destinationLabel)")
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Palette.secondaryText)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .foregroundStyle(Theme.Palette.secondaryText)
                .accessibilityHidden(true)
        }
        .padding(Theme.Spacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .flightCard()
        .accessibilityElement(children: .combine)
        .accessibilityHint("View this route's upcoming and past flights")
    }
}

#if DEBUG
#Preview("Empty favorites") {
    FavoritesTab(dependencies: .preview())
}
#endif
