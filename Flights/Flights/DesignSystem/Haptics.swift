import UIKit

/// Immediate feedback for accepted button actions, including actions that remove their view.
/// Selection and completion feedback use SwiftUI's state-driven sensoryFeedback modifiers.
@MainActor
enum Haptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.65)
    }
}
