import Foundation
import OSLog

/// Replace this adapter at composition time; features never import a vendor analytics SDK.
/// Implementations must return promptly. A network adapter should own its asynchronous queue.
@MainActor
protocol AnalyticsLogging {
    func log(_ event: AnalyticsEvent)
}

@MainActor
struct NoOpAnalyticsLogger: AnalyticsLogging {
    func log(_ event: AnalyticsEvent) {}
}

/// Local-only structured logs, visible in Xcode/Console under the analytics category.
@MainActor
struct ConsoleAnalyticsLogger: AnalyticsLogging {
    private let logger = Logger(subsystem: "com.interview.Flights", category: "analytics")

    func log(_ event: AnalyticsEvent) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        guard let data = try? encoder.encode(event),
              let message = String(data: data, encoding: .utf8) else { return }
        logger.info("\(message, privacy: .public)")
    }
}
