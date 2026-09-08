@testable import Flights
import Foundation
import SwiftUI
import Testing

@MainActor
@Suite("App preferences")
struct AppPreferencesTests {
    @Test("Haptics default on and retain an explicit off preference")
    func hapticsPreference() throws {
        let suite = "AppPreferencesTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        #expect(AppPreferences.hapticsEnabled(in: defaults))
        defaults.set(false, forKey: AppPreferences.hapticsKey)
        let reopened = try #require(UserDefaults(suiteName: suite))
        #expect(!AppPreferences.hapticsEnabled(in: reopened))
        defaults.set(true, forKey: AppPreferences.hapticsKey)
        #expect(AppPreferences.hapticsEnabled(in: reopened))
    }

    @Test("Appearance supports system inheritance and explicit overrides")
    func appearanceMapping() {
        #expect(AppAppearance.system.colorScheme == nil)
        #expect(AppAppearance.light.colorScheme == .light)
        #expect(AppAppearance.dark.colorScheme == .dark)
        for appearance in AppAppearance.allCases {
            #expect(AppAppearance(rawValue: appearance.rawValue) == appearance)
        }
    }
}
