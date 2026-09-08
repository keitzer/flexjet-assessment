import SwiftUI

/// The Complete / Completed action at the bottom of the detail screen.
///
/// Filled and maroon once complete, outlined before — the state is carried by fill and label
/// together rather than colour alone.
struct CompleteButton: View {
    let isComplete: Bool
    let action: () -> Void
    @ScaledMetric(relativeTo: .subheadline) private var iconSize = Theme.Size.completionIcon

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.small) {
                Image(systemName: isComplete ? "checkmark.seal.fill" : "checkmark.seal")
                    .frame(width: iconSize, height: iconSize)
                    .contentTransition(.symbolEffect(.replace))
                title
            }
            .font(Theme.Typography.emphasizedBody)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.medium)
            .foregroundStyle(isComplete ? .white : Theme.Palette.primaryText)
            .background {
                RoundedRectangle(cornerRadius: Theme.Radius.button)
                    .fill(isComplete ? Theme.Palette.brand : Theme.Palette.card)
            }
            .overlay {
                RoundedRectangle(cornerRadius: Theme.Radius.button)
                    .strokeBorder(
                        isComplete ? .clear : Theme.Palette.cardBorder,
                        lineWidth: 1
                    )
            }
        }
        .buttonStyle(.plain)
        .onChange(of: isComplete) { Haptics.tap() }
        .animation(.snappy(duration: 0.25), value: isComplete)
        .accessibilityLabel(isComplete ? "Completed" : "Complete")
        .accessibilityHint(isComplete ? "Marks this flight as not complete" : "Marks this flight complete")
    }

    private var title: some View {
        // Reserve the larger label's natural width in both states, including Dynamic Type.
        // This keeps the centered group and icon stationary when the text changes.
        ZStack {
            Text("Complete")
            Text("Completed")
        }
        .hidden()
        .overlay(alignment: .leading) {
            Text(isComplete ? "Completed" : "Complete")
                .contentTransition(.opacity)
        }
        .accessibilityHidden(true)
    }
}

#Preview("Complete button") {
    @Previewable @State var isComplete = false
    VStack(spacing: Theme.Spacing.large) {
        CompleteButton(isComplete: isComplete) { isComplete.toggle() }
        CompleteButton(isComplete: true) {}
    }
    .padding()
    .background(Theme.Palette.screen)
}
