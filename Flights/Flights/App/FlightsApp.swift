import SwiftUI

@main
struct FlightsApp: App {
    /// Built once and handed down; nothing in the app reaches for a shared singleton.
    @State private var dependencies = AppDependencies.live()

    var body: some Scene {
        WindowGroup {
            RootView(dependencies: dependencies)
        }
    }
}
