import UIKit

/// Immediate feedback for accepted button actions, including actions that remove their view.
/// Filters, tabs and completion use matching state-driven SwiftUI impact feedback.
@MainActor
enum Haptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: 1)
    }
}
