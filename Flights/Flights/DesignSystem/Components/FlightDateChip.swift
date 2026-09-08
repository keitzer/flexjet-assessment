import SwiftUI

/// The leading month/day block on a flight row.
///
/// Two-tone, as in the design: a tinted month band above a near-white body, which reads as a
/// torn-off calendar page. Upcoming flights tint the band with the brand colour; past flights use
/// a neutral grey so they recede.
struct FlightDateChip: View {
    enum Style {
        case upcoming
        case past

        var bandColor: Color {
            switch self {
            case .upcoming: Theme.Palette.brandSoft
            case .past: Theme.Palette.neutralChip
            }
        }

        var monthColor: Color {
            switch self {
            case .upcoming: Theme.Palette.brand
            case .past: Theme.Palette.secondaryText
            }
        }
    }

    let month: String
    let day: String
    var style: Style = .upcoming

    var body: some View {
        VStack(spacing: 0) {
            Text(month)
                .font(Theme.Typography.dateMonth)
                .foregroundStyle(style.monthColor)
                .frame(maxWidth: .infinity)
                .frame(height: Theme.Size.dateChipMonthBand)
                .background(style.bandColor)
            Text(day)
                .font(Theme.Typography.dateDay)
                .foregroundStyle(Theme.Palette.primaryText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.Palette.chipBody)
        }
        .monospacedDigit()
        .frame(width: Theme.Size.dateChip, height: Theme.Size.dateChip)
        .clipShape(.rect(cornerRadius: Theme.Radius.chip))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(month) \(day)")
    }
}

#Preview("Date chip") {
    HStack(spacing: Theme.Spacing.large) {
        FlightDateChip(month: "OCT", day: "29", style: .upcoming)
        FlightDateChip(month: "OCT", day: "25", style: .past)
    }
    .padding()
}
