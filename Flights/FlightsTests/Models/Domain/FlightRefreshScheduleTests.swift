@testable import Flights
import Foundation
import Testing

@Suite("Flight presentation refresh schedule")
struct FlightRefreshScheduleTests {
    private let calendar = Fixtures.calendar(in: Fixtures.eastern)

    @Test("Local midnight is scheduled rather than UTC midnight", arguments: [
        "2026-03-08T04:59:50Z", "2026-03-09T03:59:50Z",
        "2026-11-01T03:59:50Z", "2026-11-02T04:59:50Z"
    ])
    func midnightAcrossDST(instant: String) {
        let now = Fixtures.date(instant)
        let next = FlightRefreshSchedule.nextRefresh(after: now, departures: [], calendar: calendar)
        #expect(next == now.addingTimeInterval(10))
        #expect(calendar.component(.hour, from: next) == 0)
        #expect(calendar.component(.minute, from: next) == 0)
    }

    @Test("Wake just after the earliest departure, including the exact boundary")
    func departureBoundary() {
        let now = Fixtures.date("2026-09-05T12:00:00Z")
        for offset in [0.0, 10.0] {
            let departure = now.addingTimeInterval(offset)
            let next = FlightRefreshSchedule.nextRefresh(
                after: now,
                departures: [now.addingTimeInterval(-30), now.addingTimeInterval(40), departure],
                calendar: calendar
            )
            #expect(next > departure)
            #expect(next.timeIntervalSince(departure) < 0.01)
        }
    }

    @Test("Past and distant departures cannot prevent periodic relative-text updates")
    func periodicCeiling() {
        let now = Fixtures.date("2026-09-05T12:00:00Z")
        let next = FlightRefreshSchedule.nextRefresh(
            after: now,
            departures: [now.addingTimeInterval(-1), now.addingTimeInterval(3600)],
            calendar: calendar
        )
        #expect(next == now.addingTimeInterval(60))
    }
}
