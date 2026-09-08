@testable import Flights
import SwiftUI
import Testing
import UIKit

@MainActor
@Suite("Theme color resolution")
struct ThemeColorTests {
    @Test("Dynamic colors can resolve on a rendering thread")
    func backgroundResolution() async {
        let color = UIColor(Theme.Palette.brand)
        let resolved = await Task.detached {
            color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark)).cgColor.alpha
        }.value
        #expect(resolved == 1)
    }
}
