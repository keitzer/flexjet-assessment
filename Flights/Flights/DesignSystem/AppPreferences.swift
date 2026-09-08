import Foundation

/// Device-local preferences, retained when the user signs out.
enum AppPreferences {
    static let hapticsKey = "settings.hapticsEnabled"
    static let appearanceKey = "settings.appearance"

    static func hapticsEnabled(in defaults: UserDefaults = .standard) -> Bool {
        defaults.object(forKey: hapticsKey) as? Bool ?? true
    }
}
