import UIKit

/// Immediate feedback for accepted button actions, including actions that remove their view.
/// All app feedback goes through this preference check, including state-driven interactions.
@MainActor
enum Haptics {
    static func tap() {
        guard AppPreferences.hapticsEnabled() else { return }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: 1)
    }
}
