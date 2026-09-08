import Combine
import SwiftUI

/// Both flight screens share lifecycle-aware invalidation; scheduling rules live in the domain.
private struct FlightTimeRefresh: ViewModifier {
    let departures: [Date]
    let refresh: @MainActor () -> Void
    @Environment(\.scenePhase) private var scenePhase
    @State private var environmentRevision = UUID()

    private struct RefreshID: Equatable {
        let isActive: Bool
        let departures: [Date]
        let revision: UUID
    }

    private var refreshID: RefreshID {
        RefreshID(isActive: scenePhase == .active, departures: departures, revision: environmentRevision)
    }

    func body(content: Content) -> some View {
        content
            .onReceive(
                NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange).receive(on: RunLoop.main)
            ) { _ in
                environmentRevision = UUID()
            }
            .onReceive(
                NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)
                    .receive(on: RunLoop.main)
            ) { _ in
                environmentRevision = UUID()
            }
            .onReceive(
                NotificationCenter.default.publisher(for: NSLocale.currentLocaleDidChangeNotification)
                    .receive(on: RunLoop.main)
            ) { _ in
                environmentRevision = UUID()
            }
            .task(id: refreshID) {
                guard scenePhase == .active else { return }
                do {
                    while !Task.isCancelled {
                        refresh()
                        let instant = Date.now
                        let next = FlightRefreshSchedule.nextRefresh(after: instant, departures: departures)
                        try await Task.sleep(for: .seconds(next.timeIntervalSince(instant)))
                    }
                } catch {
                    // Disappearance, backgrounding and rescheduling cancel the sleep.
                }
            }
    }
}

extension View {
    func refreshFlightTime(departures: [Date], refresh: @escaping @MainActor () -> Void) -> some View {
        modifier(FlightTimeRefresh(departures: departures, refresh: refresh))
    }
}
