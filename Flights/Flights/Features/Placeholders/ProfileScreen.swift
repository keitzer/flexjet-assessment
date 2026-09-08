import SwiftUI

/// The Profile tab. Minimal, but real: it is where signing out lives.
struct ProfileScreen: View {
    @Environment(\.dependencies) private var dependencies

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label("Signed in", systemImage: "person.crop.circle")
                        .foregroundStyle(Theme.Palette.primaryText)
                }
                Section {
                    Button("Sign Out", role: .destructive) {
                        dependencies.session.endSession()
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#if DEBUG
#Preview("Profile") {
    ProfileScreen()
        .environment(\.dependencies, .preview())
}
#endif
