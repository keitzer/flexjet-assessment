import SwiftUI

/// Shared loaded/loading/error/empty states and row navigation for all flight lists.
struct FlightResultsView: View {
    let viewModel: FlightListViewModel
    @State private var retryTask: Task<Void, Never>?
    @Environment(FlightsRouter.self) private var router

    @ViewBuilder
    var body: some View {
        Group {
            content
        }
        .onDisappear { retryTask?.cancel() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            FlightListSkeleton()
        case .failed(let error):
            ErrorStateView(error: error) {
                guard retryTask == nil else { return }
                Haptics.tap()
                retryTask = Task {
                    defer { retryTask = nil }
                    await viewModel.load()
                }
            }
        case .loaded:
            if viewModel.isShowingEmptyState {
                EmptyFlightsStateView(category: viewModel.selectedCategory)
            } else {
                list
            }
        }
    }

    private var list: some View {
        ScrollView {
            LazyVStack(spacing: Theme.Spacing.medium) {
                ForEach(viewModel.items) { item in
                    Button {
                        Haptics.tap()
                        router.showDetail(item.flight)
                    } label: {
                        FlightRow(model: item.model)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Theme.Spacing.large)
            .padding(.bottom, Theme.Spacing.large)
        }
        // Each category starts at the top with fresh lazy-layout and scroll state.
        .id(viewModel.selectedCategory)
    }
}
