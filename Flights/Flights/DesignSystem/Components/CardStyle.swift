import SwiftUI

/// The white rounded container used by every flight row and detail field.
private struct CardStyle: ViewModifier {
    let elevated: Bool

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .fill(Theme.Palette.card)
                    .shadow(
                        color: elevated ? Theme.Shadow.todayColor : .clear,
                        radius: Theme.Shadow.todayRadius,
                        y: Theme.Shadow.todayOffset
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .strokeBorder(Theme.Palette.cardBorder, lineWidth: 1)
            }
    }
}

extension View {
    /// Applies the shared card background and hairline border.
    func flightCard(elevated: Bool = false) -> some View {
        modifier(CardStyle(elevated: elevated))
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
