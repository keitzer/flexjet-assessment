import SwiftUI

/// Central design tokens taken from the Figma spec.
///
/// Views should reference these tokens instead of hard-coded colors or numbers so that
/// restyling the app is a single-file change.
enum Theme {
    enum Palette {
        /// Flexjet maroon, taken from the Figma export.
        static let brand = Color(hex: 0x93272C)
        /// Month-band tint on an upcoming flight's date chip: the brand at 18%.
        static let brandSoft = brand.opacity(0.18)

        static let screen = Color(.systemBackground)
        static let card = Color(.secondarySystemGroupedBackground)
        static let cardBorder = Color(hex: 0xE5E5E5)
        /// The near-white lower portion of a date chip.
        static let chipBody = Color(hex: 0xFAFAFA)

        /// Neutral month band used by past flights, which are de-emphasised.
        static let neutralChip = Color(hex: 0xE5E5E5)
        static let segmentTrack = Color(hex: 0x767680).opacity(0.12)

        static let primaryText = Color(hex: 0x262626)
        static let secondaryText = Color(hex: 0x737373)
    }

    enum Spacing {
        static let xSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 24
    }

    enum Radius {
        static let chip: CGFloat = 4
        static let card: CGFloat = 16
        static let button: CGFloat = 8
        static let pill: CGFloat = 100
    }

    /// Fixed sizes taken from the design.
    enum Size {
        /// The date chip is a 48-point square with an 18-point month band.
        static let dateChip: CGFloat = 48
        static let dateChipMonthBand: CGFloat = 18
    }
}

extension Color {
    /// Builds a color from a `0xRRGGBB` literal, keeping design tokens readable.
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}
