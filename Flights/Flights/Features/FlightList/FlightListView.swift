import SwiftUI

/// The Flights screen: a segmented Upcoming/Past list of flight cards.
struct FlightListView: View {
    @State private var viewModel: FlightListViewModel
    @State private var isShowingAddFlight = false
    @State private var retryTask: Task<Void, Never>?
    @Environment(FlightsRouter.self) private var router

    init(dependencies: AppDependencies) {
        _viewModel = State(
            wrappedValue: FlightListViewModel(
                apiClient: dependencies.apiClient,
                session: dependencies.session,
                completion: dependencies.completion
            )
        )
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: Theme.Spacing.large) {
            header
            SegmentedFilterControl(
                items: FlightCategory.allCases,
                title: \.title,
                selection: $viewModel.selectedCategory
            )
            .padding(.horizontal, Theme.Spacing.large)
            content
        }
        .background(Theme.Palette.screen)
        // The design puts the title and the "+" on one row, so the header is drawn in content
        // rather than as a navigation title, whose toolbar item would sit in a separate bar.
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.loadIfNeeded() }
        .refreshable { await viewModel.load() }
        .onDisappear { retryTask?.cancel() }
        .sheet(isPresented: $isShowingAddFlight) { AddFlightPlaceholder() }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Flights")
                .font(.largeTitle.weight(.bold))
                .accessibilityAddTraits(.isHeader)
            Spacer()
            // The brief specifies no "add flight" flow, so the button matches the design and
            // opens an honest placeholder rather than doing nothing.
            AddFlightButton { isShowingAddFlight = true }
        }
        .padding(.horizontal, Theme.Spacing.large)
        .padding(.top, Theme.Spacing.large)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingStateView()
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
        // Re-animate the list when the user switches segments.
        .animation(.snappy(duration: 0.25), value: viewModel.selectedCategory)
    }
}

#if DEBUG
private struct FlightListPreview: View {
    let dependencies: AppDependencies

    var body: some View {
        NavigationStack {
            FlightListView(dependencies: dependencies)
        }
        .environment(FlightsRouter())
        .environment(\.dependencies, dependencies)
    }
}
#endif

#if DEBUG
#Preview("Loaded") {
    FlightListPreview(dependencies: .preview())
}

#Preview("Empty") {
    FlightListPreview(dependencies: .preview(apiClient: MockFlightsAPIClient.empty))
}

#Preview("Error") {
    FlightListPreview(dependencies: .preview(apiClient: MockFlightsAPIClient.failing))
}

#Preview("Loading") {
    FlightListPreview(dependencies: .preview(apiClient: MockFlightsAPIClient.loading))
}
#endif
