@testable import Flights
import Foundation
import Testing

@Suite("ISO-8601 parsing")
struct ISO8601ParsingTests {
    @Test("Accepts the fractional-second form the live service sends")
    func parsesFractionalSeconds() {
        let parsed = ISO8601Parsing.date(from: "2026-09-05T12:00:00.000Z")
        #expect(parsed == Date(timeIntervalSince1970: 1_788_609_600))
    }

    @Test("Accepts the plain form shown in the API documentation")
    func parsesWholeSeconds() {
        let parsed = ISO8601Parsing.date(from: "2026-09-05T12:00:00Z")
        #expect(parsed == Date(timeIntervalSince1970: 1_788_609_600))
    }

    @Test("Rejects a value that is not a timestamp", arguments: ["", "tomorrow", "2026-13-45T99:99:99Z"])
    func rejectsMalformedValues(value: String) {
        #expect(ISO8601Parsing.date(from: value) == nil)
    }
}
