import SwiftUI

extension Theme {
    /// Shared text roles. System styles retain Dynamic Type until the Figma fonts are supplied.
    /// Change font families here without editing individual screens.
    enum Typography {
        static let screenTitle = Font.largeTitle.weight(.bold)
        static let body = Font.subheadline
        static let emphasizedBody = Font.subheadline.weight(.semibold)
        static let detailField = Font.subheadline.weight(.bold)
        static let caption = Font.footnote
        static let fieldLabel = Font.footnote.weight(.medium)
        static let primaryButton = Font.headline
        static let dateMonth = Font.caption2.weight(.semibold)
        static let dateDay = Font.title3.weight(.bold)

        // SF Symbol sizing is independent of the text font family.
        static let actionIcon = Font.title2
        static let loginIcon = Font.system(size: 44, weight: .semibold)
    }
}
