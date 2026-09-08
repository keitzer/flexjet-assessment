@testable import Flights

@MainActor
final class RecordingAnalyticsLogger: AnalyticsLogging {
    private(set) var events: [AnalyticsEvent] = []

    func log(_ event: AnalyticsEvent) {
        events.append(event)
    }
}
