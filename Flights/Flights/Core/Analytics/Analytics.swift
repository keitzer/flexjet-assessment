import Foundation

/// Consistent event names and reserved properties in front of any analytics provider.
@MainActor
struct Analytics {
    let logger: AnalyticsLogging
    var now: @Sendable () -> Date = { .now }
    static let disabled = Self(logger: NoOpAnalyticsLogger())

    func page(_ page: AnalyticsPage, context: AnalyticsContext = .empty) {
        emit("page_view", page: page, properties: context.properties)
    }

    func button(_ action: AnalyticsAction, page: AnalyticsPage, context: AnalyticsContext = .empty) {
        var properties = context.properties
        properties["action"] = .string(action.rawValue)
        emit("button_press", page: page, properties: properties)
    }

    func change(
        _ status: AnalyticsStatus,
        page: AnalyticsPage,
        from oldValue: AnalyticsValue,
        to newValue: AnalyticsValue,
        context: AnalyticsContext = .empty
    ) {
        guard oldValue != newValue else { return }
        var properties = context.properties
        properties["status"] = .string(status.rawValue)
        properties["previous_value"] = oldValue
        properties["value"] = newValue
        emit("status_change", page: page, properties: properties)
    }

    private func emit(_ name: String, page: AnalyticsPage, properties: [String: AnalyticsValue]) {
        var properties = properties
        properties["schema_version"] = .integer(1)
        logger.log(AnalyticsEvent(name: name, page: page, timestamp: now(), properties: properties))
    }
}
