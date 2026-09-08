import SwiftUI

/// A moving highlight masked to placeholder shapes. No tasks or timers outlive the view.
struct Shimmer: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.layoutDirection) private var layoutDirection

    func body(content: Content) -> some View {
        content.overlay {
            if !reduceMotion, scenePhase == .active {
                TimelineView(.animation(minimumInterval: 1.0 / 30)) { context in
                    GeometryReader { geometry in
                        let phase = context.date.timeIntervalSinceReferenceDate
                            .truncatingRemainder(dividingBy: 1.6) / 1.6
                        let progress = layoutDirection == .rightToLeft ? 1 - phase : phase
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.35), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * 0.6)
                        .offset(x: geometry.size.width * (progress * 1.6 - 0.6))
                    }
                }
                .mask(content)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
        }
    }
}
