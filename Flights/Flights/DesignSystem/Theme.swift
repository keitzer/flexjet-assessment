import SwiftUI

/// Central design tokens taken from the Figma spec.
///
/// Views should reference these tokens instead of hard-coded colors or numbers so that
/// restyling the app is a single-file change.
enum Theme {
    enum Palette {
        /// Flexjet maroon, taken from the Figma export.
        static let brand = Color(light: 0x93272C, dark: 0xBC4B55)
        /// Month-band tint on an upcoming flight's date chip: the brand at 18%.
        static let brandSoft = brand.opacity(0.18)

        static let screen = Color(.systemBackground)
        static let card = Color(.secondarySystemGroupedBackground)
        static let cardBorder = Color(light: 0xE5E5E5, dark: 0x48484A)
        /// The near-white lower portion of a date chip.
        static let chipBody = Color(light: 0xFAFAFA, dark: 0x2C2C2E)

        /// Neutral month band used by past flights, which are de-emphasised.
        static let neutralChip = Color(light: 0xE5E5E5, dark: 0x48484A)
        static let segmentTrack = Color(.tertiarySystemFill)
        static let segmentSelection = Color(light: 0xFFFFFF, dark: 0x48484A)
        static let segmentOutline = Color(light: 0xFFFFFF, dark: 0x8E8E93)
        static let skeleton = Color(light: 0xE5E5EA, dark: 0x3A3A3C)

        static let primaryText = Color(light: 0x262626, dark: 0xF2F2F7)
        static let secondaryText = Color(light: 0x737373, dark: 0xAEAEB2)
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

    /// Subtle Today-card elevation, approximated from the supplied design screenshot.
    enum Shadow {
        static let todayColor = Color.black.opacity(0.12)
        static let todayRadius: CGFloat = 6
        static let todayOffset: CGFloat = 3
    }

    /// Shared layout dimensions from the design and app-specific layout choices.
    enum Size {
        /// The date chip is a 48-point square with an 18-point month band.
        static let dateChip: CGFloat = 48
        static let dateChipMonthBand: CGFloat = 18
        /// Keeps the sign-in form readable on wider devices.
        static let loginFormMaxWidth: CGFloat = 480
        /// Figma's rounded 15-point text line box; scaled by the consuming view.
        static let detailFieldMinHeight: CGFloat = 23
    }
}

extension Color {
    /// Resolves against the presentation's appearance, including the user's in-app override.
    /// UIKit can resolve dynamic colors on SwiftUI's background renderer. Creating the provider
    /// outside MainActor prevents its closure from inheriting a main-queue runtime assertion.
    nonisolated init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            let hex = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(
                red: Double((hex >> 16) & 0xFF) / 255,
                green: Double((hex >> 8) & 0xFF) / 255,
                blue: Double(hex & 0xFF) / 255,
                alpha: 1
            )
        })
    }

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
