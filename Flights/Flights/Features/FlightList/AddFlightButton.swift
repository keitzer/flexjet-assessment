import SwiftUI

/// The filled maroon "+" in the Flights navigation bar.
///
/// Uses `plus.square.fill`, the symbol named on the design's icon sheet, so the glyph and its
/// rounded container come from SF Symbols rather than being rebuilt by hand.
struct AddFlightButton: View {
    let action: () -> Void
    @Environment(\.analytics) private var analytics

    var body: some View {
        Button {
            analytics.button(.addFlight, page: .flights)
            Haptics.tap()
            action()
        } label: {
            Image(systemName: "plus.square.fill")
                .font(Theme.Typography.actionIcon)
                .foregroundStyle(Theme.Palette.brand)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add flight")
    }
}

/// Stands in for the unspecified "add flight" flow.
struct AddFlightPlaceholder: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.analytics) private var analytics

    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label("Add a Flight", systemImage: "airplane.departure")
            } description: {
                Text("The brief doesn't define this flow, so it's left as a placeholder.")
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        analytics.button(.dismissAddFlight, page: .addFlight)
                        Haptics.tap()
                        dismiss()
                    }
                    .tint(Theme.Palette.brand)
                }
            }
        }
        .presentationDetents([.medium])
        .analyticsPage(.addFlight)
    }
}

#Preview("Add button") {
    AddFlightButton {}
        .padding()
}

#Preview("Add placeholder") {
    AddFlightPlaceholder()
}
