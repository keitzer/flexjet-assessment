import SwiftUI

/// The white rounded container used by every flight row and detail field.
private struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Theme.Palette.card, in: .rect(cornerRadius: Theme.Radius.card))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .strokeBorder(Theme.Palette.cardBorder, lineWidth: 1)
            }
    }
}

extension View {
    /// Applies the shared card background and hairline border.
    func flightCard() -> some View {
        modifier(CardStyle())
    }
}

#Preview("Card style") {
    VStack {
        Text("Card contents")
            .padding()
            .frame(maxWidth: .infinity)
            .flightCard()
    }
    .padding()
    .background(Theme.Palette.screen)
}
