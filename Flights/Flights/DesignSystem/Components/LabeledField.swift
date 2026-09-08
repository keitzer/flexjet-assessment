import SwiftUI

/// A titled text-entry row used by the login form.
struct LabeledField<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
            Text(title)
                .font(Theme.Typography.fieldLabel)
                .foregroundStyle(Theme.Palette.secondaryText)
            content
                .textFieldStyle(.plain)
                .padding(Theme.Spacing.medium)
                .flightCard()
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
