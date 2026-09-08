import SwiftUI

/// A single row in the Flights list.
///
/// Renders a `FlightRowModel` and nothing more — no dates, no comparisons, no branching on
/// business rules beyond which elements the model says are present.
struct FlightRow: View {
    let model: FlightRowModel

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.medium) {
            FlightDateChip(month: model.month, day: model.day, style: model.isPast ? .past : .upcoming)
            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                Text(model.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.Palette.primaryText)
                    // The service ships a 72-character origin label, so allow a second line
                    // before truncating rather than squeezing the row.
                    .lineLimit(2)
                Text(model.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Theme.Palette.secondaryText)
                if model.showsTodayBadge {
                    FlightTodayBadge()
                        .padding(.top, Theme.Spacing.xSmall)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if model.showsCompletion {
                CompletionIndicator(isComplete: model.isComplete)
            }
        }
        .padding(Theme.Spacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .flightCard()
        .contentShape(.rect)
    }
}

#if DEBUG
private func previewModel(_ flight: Flight, isComplete: Bool = false) -> FlightRowModel {
    FlightRowModelBuilder().make(from: flight, isComplete: isComplete, now: .now)
}
#endif

#Preview("Rows") {
    ScrollView {
        VStack(spacing: Theme.Spacing.medium) {
            FlightRow(model: previewModel(.sampleToday))
            FlightRow(model: previewModel(.sampleLongName))
            FlightRow(model: previewModel(.samplePast))
            FlightRow(model: previewModel(.samplePast, isComplete: true))
            FlightRow(model: previewModel(.sampleMissingFlightNumber))
        }
        .padding()
    }
    .background(Theme.Palette.screen)
}
