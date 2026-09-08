import SwiftUI

/// Account actions and device-local settings.
struct ProfileScreen: View {
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
                        Haptics.tap()
                        dependencies.session.endSession()
                    }
                }
            }
            .navigationTitle("Profile")
            .onChange(of: hapticsEnabled) { Haptics.tap() }
            .onChange(of: appearance) { Haptics.tap() }
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
