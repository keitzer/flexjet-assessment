@testable import Flights
import SwiftUI
import Testing
import UIKit

@MainActor
@Suite("Completion rendering", .serialized)
struct CompletionRenderingTests {
    @Test("Rendered completion survives repeated state transitions")
    func repeatedCompletion() async throws {
        let completion = FlightCompletionStore(storage: InMemoryCompletionStorage())
        let controller = UIHostingController(rootView: CompletionHarness(completion: completion))
        let scene = try #require(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window = UIWindow(windowScene: scene)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        defer {
            window.isHidden = true
            window.rootViewController = nil
        }
        for _ in 0..<6 {
            completion.toggle("flight")
            controller.view.layoutIfNeeded()
            try await Task.sleep(for: .milliseconds(350))
        }
        #expect(!completion.isComplete("flight"))
    }
}

private struct CompletionHarness: View {
    let completion: FlightCompletionStore

    var body: some View {
        CompleteButton(isComplete: completion.isComplete("flight")) {
            completion.toggle("flight")
        }
        .padding()
    }
}
