import SwiftUI

/// A moving highlight masked to placeholder shapes. No tasks or timers outlive the view.
struct Shimmer: ViewModifier {
    private enum Effect {
        static let duration = 1.6
        static let frameInterval = 1.0 / 30
        static let highlightWidth = 0.6
        static let highlightOpacity = 0.35
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.layoutDirection) private var layoutDirection

    func body(content: Content) -> some View {
        content.overlay {
            if !reduceMotion, scenePhase == .active {
                TimelineView(.animation(minimumInterval: Effect.frameInterval)) { context in
                    GeometryReader { geometry in
                        let phase = context.date.timeIntervalSinceReferenceDate
                            .truncatingRemainder(dividingBy: Effect.duration) / Effect.duration
                        let progress = layoutDirection == .rightToLeft ? 1 - phase : phase
                        let offset = progress * (1 + Effect.highlightWidth) - Effect.highlightWidth
                        LinearGradient(
                            colors: [.clear, .white.opacity(Effect.highlightOpacity), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * Effect.highlightWidth)
                        .offset(x: geometry.size.width * offset)
                    }
                }
                .mask(content)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
        }
    }
}
