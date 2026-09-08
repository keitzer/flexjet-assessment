import SwiftUI

/// The seal-check mark on a flight row, filled once the flight is marked complete.
struct CompletionIndicator: View {
    let isComplete: Bool

    var body: some View {
        Image(systemName: isComplete ? "checkmark.seal.fill" : "checkmark.seal")
            .font(Theme.Typography.actionIcon)
            .foregroundStyle(isComplete ? Theme.Palette.brand : Theme.Palette.primaryText)
            .contentTransition(.symbolEffect(.replace))
            .accessibilityLabel(isComplete ? "Completed" : "Not completed")
    }
}

#Preview("Completion indicator") {
    HStack(spacing: Theme.Spacing.large) {
        CompletionIndicator(isComplete: false)
        CompletionIndicator(isComplete: true)
    }
    .padding()
}
