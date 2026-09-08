import SwiftUI

extension EnvironmentValues {
    @Entry var analytics: Analytics = .disabled
}

extension View {
    /// One event per appearance, including returning from a pushed screen; never emitted from body.
    func analyticsPage(_ page: AnalyticsPage, context: AnalyticsContext = .empty) -> some View {
        modifier(AnalyticsPageView(page: page, context: context))
    }
}

private struct AnalyticsPageView: ViewModifier {
    let page: AnalyticsPage
    let context: AnalyticsContext
    @Environment(\.analytics) private var analytics

    func body(content: Content) -> some View {
        content.onAppear { analytics.page(page, context: context) }
    }
}
