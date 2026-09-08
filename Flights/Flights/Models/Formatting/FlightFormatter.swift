import Foundation

/// Turns flight values into the strings the design calls for.
///
/// Locale, calendar and time zone are injected and default to the autoupdating ones, which is how
/// the spec's "display flight times in the current user's time zone" requirement is met: the
/// service sends UTC instants and every string produced here is rendered in the device's zone.
/// Injecting them also lets tests pin a zone and assert exact output.
nonisolated struct FlightFormatter: Sendable {
    private let locale: Locale
    private let calendar: Calendar
    private let timeZone: TimeZone

    init(
        locale: Locale = .autoupdatingCurrent,
        calendar: Calendar = .autoupdatingCurrent,
        timeZone: TimeZone = .autoupdatingCurrent
    ) {
        self.locale = locale
        var displayCalendar = calendar
        displayCalendar.timeZone = timeZone
        self.calendar = displayCalendar
        self.timeZone = timeZone
    }

    private var base: Date.FormatStyle {
        Date.FormatStyle(
            date: .omitted,
            time: .omitted,
            locale: locale,
            calendar: calendar,
            timeZone: timeZone
        )
    }

    /// Uppercased month for the date chip, e.g. `"OCT"`.
    func monthAbbreviation(for date: Date) -> String {
        date.formatted(base.month(.abbreviated)).uppercased(with: locale)
    }

    /// Zero-padded day for the date chip, e.g. `"03"`.
    func dayOfMonth(for date: Date) -> String {
        date.formatted(base.day(.twoDigits))
    }

    /// Clock time for a single instant, e.g. `"6:00 PM"`.
    func time(for date: Date) -> String {
        date.formatted(base.hour(.defaultDigits(amPM: .abbreviated)).minute(.twoDigits))
    }

    /// Departure–arrival range, e.g. `"6:00 PM - 7:00 AM"`.
    ///
    /// An overnight arrival is not annotated here; the design shows a plain range.
    func timeRange(from departure: Date, to arrival: Date) -> String {
        "\(time(for: departure)) - \(time(for: arrival))"
    }

    /// Month and day for the detail screen, e.g. `"Oct 25"`.
    func shortDate(for date: Date) -> String {
        date.formatted(base.month(.abbreviated).day(.defaultDigits))
    }

    /// Detail screen's departure line, e.g. `"Oct 25 (2w ago)"`.
    func departureDescription(for date: Date, now: Date) -> String {
        "\(shortDate(for: date)) (\(relativeDescription(for: date, now: now)))"
    }

    /// Compact relative phrase describing `date` from the standpoint of `now`,
    /// e.g. `"2w ago"` for a past departure or `"in 3d"` for an upcoming one.
    ///
    /// Note the argument order: `AnchoredRelativeFormatStyle` describes the *anchor* relative to
    /// the value being formatted, which is the opposite of how it reads. Formatting `now` with
    /// the flight's date as the anchor is what yields "2w ago" rather than "in 2w".
    /// `FlightFormatterTests` pins this in both directions.
    func relativeDescription(for date: Date, now: Date) -> String {
        var style = Date.AnchoredRelativeFormatStyle(
            anchor: date,
            presentation: .numeric,
            unitsStyle: .narrow
        )
        style.locale = locale
        style.calendar = calendar
        return now.formatted(style)
    }

    /// Whole-dollar price, e.g. `"$349"`.
    ///
    /// The service sends a bare integer with no currency field, so USD is assumed; the design
    /// shows a `$` prefix and no decimal places.
    func price(_ amount: Decimal) -> String {
        amount.formatted(
            .currency(code: "USD")
                .locale(locale)
                .precision(.fractionLength(0))
        )
    }
}
