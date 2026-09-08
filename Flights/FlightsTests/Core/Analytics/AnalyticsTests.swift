@testable import Flights
import Foundation
import Testing

@MainActor
@Suite("Analytics reporting contract")
struct AnalyticsTests {
    @Test("Events have stable names, controlled time and reserved metadata")
    func eventContract() throws {
        let recorder = RecordingAnalyticsLogger()
        let instant = Date(timeIntervalSince1970: 100)
        let analytics = Analytics(logger: recorder) { instant }
        let context = AnalyticsContext(properties: ["schema_version": .integer(99), "action": .string("spoof")])
        analytics.page(.profile)
        analytics.button(.selectTheme, page: .profile, context: context)
        analytics.change(.theme, page: .profile, from: .string("system"), to: .string("dark"))
        analytics.change(.haptics, page: .profile, from: .bool(true), to: .bool(false))
        analytics.change(.haptics, page: .profile, from: .bool(false), to: .bool(false))
        #expect(recorder.events.map(\.name) == ["page_view", "button_press", "status_change", "status_change"])
        #expect(recorder.events.allSatisfy { $0.timestamp == instant && $0.page == .profile })
        #expect(recorder.events.allSatisfy { $0.properties["schema_version"] == .integer(1) })
        #expect(recorder.events[1].properties["action"] == .string("select_theme"))
        #expect(recorder.events[2].properties["previous_value"] == .string("system"))
        #expect(recorder.events[2].properties["value"] == .string("dark"))
        let data = try JSONEncoder().encode(recorder.events[3])
        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let properties = try #require(json["properties"] as? [String: Any])
        #expect(properties["value"] as? Bool == false)
        #expect(properties["schema_version"] as? Int == 1)
        #expect(properties["status"] as? String == "haptics")
        ConsoleAnalyticsLogger().log(recorder.events[3])
    }

    @Test("Flight context contains only reporting identifiers, including normalized route codes")
    func contextAllowlist() {
        let flight = RouteFixtures.flight(origin: " sfo ", destination: "sea")
        #expect(AnalyticsContext.flight(flight).properties == [
            "origin_iata": .string("SFO"), "destination_iata": .string("SEA"),
            "flight_id": .string("flight"), "flight_number": .string("UA100")
        ])
        let noNumber = Fixtures.flight(
            departure: "2026-09-08T07:00:00Z", arrival: "2026-09-08T10:00:00Z", flightNumber: nil
        )
        #expect(AnalyticsContext.flight(noNumber).properties["flight_number"] == nil)
    }

    @Test("Failure codes are stable categories without raw error messages")
    func failureCodes() {
        let errors: [APIError] = [
            .invalidCredentials, .sessionExpired, .offline, .server(status: 500), .decoding, .unknown
        ]
        #expect(errors.map(\.analyticsCode) == [
            "invalid_credentials", "session_expired", "offline", "server", "decoding", "unknown"
        ])
    }
}
