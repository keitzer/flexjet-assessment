import SwiftUI

/// Shown when a request fails, with a retry affordance.
struct ErrorStateView: View {
    let error: APIError
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Couldn't load flights", systemImage: "exclamationmark.triangle")
        } description: {
            Text(error.localizedDescription)
        } actions: {
            Button("Try Again", action: retry)
                .buttonStyle(.borderedProminent)
                .tint(Theme.Palette.brand)
        }
    }
}

/// Shown when a segment has loaded successfully but contains no flights.
struct EmptyFlightsStateView: View {
    let category: FlightCategory

    private var message: String {
        switch category {
        case .upcoming: "Flights you have coming up will appear here."
        case .past: "Flights you've already taken will appear here."
        }
    }

    var body: some View {
        ContentUnavailableView {
            Label("No \(category.title) Flights", systemImage: "airplane")
        } description: {
            Text(message)
        }
    }
}

#Preview("Error") {
    ErrorStateView(error: .offline) {}
}

#Preview("Empty") {
    EmptyFlightsStateView(category: .upcoming)
}
