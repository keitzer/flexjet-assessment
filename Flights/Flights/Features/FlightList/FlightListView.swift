import SwiftUI

/// The Flights screen: a segmented Upcoming/Past list of flight cards.
struct FlightListView: View {
    @Environment(\.analytics) private var analytics
    @State private var viewModel: FlightListViewModel
    @State private var isShowingAddFlight = false

    init(dependencies: AppDependencies) {
        _viewModel = State(
            wrappedValue: FlightListViewModel(
                apiClient: dependencies.apiClient,
                session: dependencies.session,
                completion: dependencies.completion,
                cache: dependencies.flightsCache,
                analytics: dependencies.analytics
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
                selection: $viewModel.selectedCategory,
                onSelect: viewModel.recordCategoryPress
            )
            .padding(.horizontal, Theme.Spacing.large)
            FlightResultsView(viewModel: viewModel)
        }
        .background(Theme.Palette.screen)
        .analyticsPage(.flights)
        // The design puts the title and the "+" on one row, so the header is drawn in content
        // rather than as a navigation title, whose toolbar item would sit in a separate bar.
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.loadIfNeeded() }
        .refreshFlightTime(departures: viewModel.flights.map(\.departure), refresh: viewModel.refreshTime)
        .refreshable {
            analytics.button(.refreshFlights, page: viewModel.analyticsPage, context: viewModel.analyticsContext)
            await viewModel.load()
        }
        .onChange(of: isShowingAddFlight) { oldValue, newValue in
            analytics.change(.addFlightPresented, page: .flights, from: .bool(oldValue), to: .bool(newValue))
        }
        .sheet(isPresented: $isShowingAddFlight) { AddFlightPlaceholder() }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Flights")
                .font(Theme.Typography.screenTitle)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            // The brief specifies no "add flight" flow, so the button matches the design and
            // opens an honest placeholder rather than doing nothing.
            AddFlightButton { isShowingAddFlight = true }
        }
        .padding(.horizontal, Theme.Spacing.large)
        .padding(.top, Theme.Spacing.large)
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
