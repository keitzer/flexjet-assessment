import SwiftUI

/// The Complete / Completed action at the bottom of the detail screen.
///
/// Filled and maroon once complete, outlined before — the state is carried by fill and label
/// together rather than colour alone.
struct CompleteButton: View {
    let isComplete: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label {
                Text(isComplete ? "Completed" : "Complete")
            } icon: {
                Image(systemName: isComplete ? "checkmark.seal.fill" : "checkmark.seal")
            }
            .font(.subheadline.weight(.semibold))
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
            .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.success, trigger: isComplete) { _, complete in complete }
        .animation(.snappy(duration: 0.25), value: isComplete)
        .accessibilityHint(isComplete ? "Marks this flight as not complete" : "Marks this flight complete")
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
