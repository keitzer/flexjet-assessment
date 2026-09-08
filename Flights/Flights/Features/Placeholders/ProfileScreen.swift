import SwiftUI

/// Account actions and device-local settings.
struct ProfileScreen: View {
    @Environment(\.analytics) private var analytics
    @Environment(\.dependencies) private var dependencies
    @AppStorage(AppPreferences.hapticsKey) private var hapticsEnabled = true
    @AppStorage(AppPreferences.appearanceKey) private var appearance = AppAppearance.system

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label("Signed in", systemImage: "person.crop.circle")
                        .foregroundStyle(Theme.Palette.primaryText)
                }
                settings
                Section {
                    Button("Sign Out", role: .destructive) {
                        analytics.button(.signOut, page: .profile)
                        Haptics.tap()
                        dependencies.session.endSession()
                    }
                }
            }
            .navigationTitle("Profile")
            .analyticsPage(.profile)
            .onChange(of: hapticsEnabled) { oldValue, newValue in
                analytics.button(.toggleHaptics, page: .profile)
                analytics.change(.haptics, page: .profile, from: .bool(oldValue), to: .bool(newValue))
                Haptics.tap()
            }
            .onChange(of: appearance) { oldValue, newValue in
                analytics.button(.selectTheme, page: .profile)
                analytics.change(
                    .theme,
                    page: .profile,
                    from: .string(oldValue.rawValue),
                    to: .string(newValue.rawValue)
                )
                Haptics.tap()
            }
        }
    }

    private var settings: some View {
        Section("Settings") {
            Toggle(isOn: $hapticsEnabled) {
                Label("Haptic Feedback", systemImage: "waveform")
            }
            Picker(selection: $appearance) {
                ForEach(AppAppearance.allCases) { option in
                    Text(option.title).tag(option)
                }
            } label: {
                Label("Appearance", systemImage: "circle.lefthalf.filled")
            }
        }
    }
}

#if DEBUG
#Preview("Profile") {
    ProfileScreen()
        .environment(\.dependencies, .preview())
}
#endif
