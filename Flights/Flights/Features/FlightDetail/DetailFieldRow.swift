import SwiftUI

/// A label/value line on the detail screen, e.g. "Trip Number  1234567".
struct DetailFieldRow: View {
    let field: FlightDetailModel.Field

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(field.label)
                .font(.subheadline)
                .foregroundStyle(Theme.Palette.secondaryText)
            Spacer(minLength: Theme.Spacing.medium)
            Text(field.value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.Palette.primaryText)
                .multilineTextAlignment(.trailing)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview("Detail fields") {
    VStack(spacing: Theme.Spacing.medium) {
        DetailFieldRow(field: .init(label: "Departure Date", value: "Oct 25 (2w ago)"))
        DetailFieldRow(field: .init(label: "Trip Number", value: "1234567"))
        DetailFieldRow(field: .init(label: "Flight Number", value: "—"))
        DetailFieldRow(field: .init(label: "Price", value: "$349"))
    }
    .padding()
}
