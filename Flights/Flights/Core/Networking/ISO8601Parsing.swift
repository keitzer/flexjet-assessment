import Foundation

/// Parses the ISO-8601 timestamps sent by the flights service.
///
/// The live feed sends fractional seconds (`2026-09-05T12:00:00.000Z`) while the published API
/// docs show the same field without them (`2025-12-10T12:20:00Z`). Both are accepted so a change
/// in the service's serialiser cannot break decoding.
nonisolated enum ISO8601Parsing {
    private static let withFractionalSeconds = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
    private static let withoutFractionalSeconds = Date.ISO8601FormatStyle(includingFractionalSeconds: false)

    /// Returns the parsed instant, or `nil` if the string matches neither supported layout.
    static func date(from value: String) -> Date? {
        if let date = try? withFractionalSeconds.parse(value) {
            return date
        }
        return try? withoutFractionalSeconds.parse(value)
    }
}
