import SwiftUI

/// A text-entry row with an accessible label and focus styling.
struct LabeledField<Content: View>: View {
    let title: String
    var symbol = "person"
    var isFocused = false
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
            HStack(spacing: Theme.Spacing.medium) {
                Image(systemName: symbol)
                    .frame(width: Theme.Login.fieldIconWidth)
                    .foregroundStyle(isFocused ? Theme.Palette.brand : Theme.Palette.secondaryText)
                    .accessibilityHidden(true)
                content
                    .accessibilityLabel(title)
                    .textFieldStyle(.plain)
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Palette.primaryText)
            }
            .padding(Theme.Spacing.large)
            .background(Theme.Palette.screen, in: .rect(cornerRadius: Theme.Radius.card))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .strokeBorder(
                        isFocused ? Theme.Palette.brand : Theme.Palette.cardBorder,
                        lineWidth: isFocused ? Theme.Login.focusedBorderWidth : 1
                    )
            }
        }
    }
}

#Preview("Labeled field") {
    @Previewable @State var text = ""
    VStack {
        LabeledField(title: "Username") {
            TextField("Username", text: $text)
        }
    }
    .padding()
}
