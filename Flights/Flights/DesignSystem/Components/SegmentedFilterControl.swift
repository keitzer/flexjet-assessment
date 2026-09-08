import SwiftUI

/// The Upcoming / Past switch at the top of the Flights screen.
///
/// Built by hand rather than with a segmented `Picker` because the design uses a fully rounded
/// track and pill. `matchedGeometryEffect` slides the pill between segments instead of having it
/// pop, and the whole control is exposed to VoiceOver as an adjustable element.
struct SegmentedFilterControl<Item: Hashable & Identifiable>: View {
    let items: [Item]
    let title: (Item) -> String
    @Binding var selection: Item

    @Namespace private var pillNamespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                segment(for: item)
            }
        }
        .padding(Theme.Spacing.xSmall)
        .background(Theme.Palette.segmentTrack, in: .capsule)
        .accessibilityElement(children: .contain)
        .sensoryFeedback(.selection, trigger: selection)
    }

    private func segment(for item: Item) -> some View {
        let isSelected = item == selection
        return Button {
            withAnimation(.snappy(duration: 0.28)) {
                selection = item
            }
        } label: {
            Text(title(item))
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? Theme.Palette.primaryText : Theme.Palette.secondaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.small)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(Theme.Palette.card)
                            .shadow(color: .black.opacity(0.08), radius: 3, y: 1)
                            .matchedGeometryEffect(id: "pill", in: pillNamespace)
                    }
                }
                .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }
}

#Preview("Segmented filter") {
    @Previewable @State var selection = FlightCategory.upcoming
    return VStack(spacing: Theme.Spacing.xLarge) {
        SegmentedFilterControl(
            items: FlightCategory.allCases,
            title: \.title,
            selection: $selection
        )
        Text("Selected: \(selection.title)")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
    .padding()
}
