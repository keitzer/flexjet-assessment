import SwiftUI

/// The flight detail screen.
struct FlightDetailView: View {
    @State private var viewModel: FlightDetailViewModel

    init(flight: Flight, dependencies: AppDependencies) {
        _viewModel = State(
            wrappedValue: FlightDetailViewModel(
                flight: flight,
                completion: dependencies.completion
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                Text(viewModel.model.title)
                    .font(.largeTitle.weight(.bold))
                    .accessibilityAddTraits(.isHeader)
                endpoints
                fields
                if viewModel.canToggleCompletion {
                    CompleteButton(isComplete: viewModel.isComplete) {
                        viewModel.toggleCompletion()
                    }
                    .padding(.top, Theme.Spacing.small)
                }
            }
            .padding(Theme.Spacing.large)
        }
        .background(Theme.Palette.screen)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var endpoints: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.medium) {
            EndpointCard(location: viewModel.model.originLabel, caption: "Origin")
            EndpointCard(location: viewModel.model.destinationLabel, caption: "Destination")
        }
    }

    // The design lists the fields as plain rows with no separators.
    private var fields: some View {
        VStack(spacing: Theme.Spacing.medium) {
            ForEach(viewModel.model.fields) { field in
                DetailFieldRow(field: field)
            }
        }
    }
}

#if DEBUG
private struct FlightDetailPreview: View {
    let flight: Flight
    var completedIDs: Set<String> = []

    var body: some View {
        let dependencies = AppDependencies.preview(completedIDs: completedIDs)
        return NavigationStack {
            FlightDetailView(flight: flight, dependencies: dependencies)
        }
    }
}
#endif

#if DEBUG
#Preview("Detail") {
    FlightDetailPreview(flight: .samplePast)
}

#Preview("Completed") {
    FlightDetailPreview(flight: .samplePast, completedIDs: [Flight.samplePast.id])
}

#Preview("Null flight number") {
    FlightDetailPreview(flight: .sampleMissingFlightNumber)
}

#Preview("Long location") {
    FlightDetailPreview(flight: .sampleLongName)
}
#endif
