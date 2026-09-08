import Foundation
import Observation

/// Drives the flight detail screen.
///
/// Holds no copy of the completion flag: it reads through to the shared store so the list's
/// checkmark and this screen's button can never disagree.
@Observable
@MainActor
final class FlightDetailViewModel {
    let flight: Flight

    private let completion: FlightCompletionStore
    private let presenter: FlightDetailPresenter
    private let classifier: FlightClassifier
    private let now: @Sendable () -> Date
    private(set) var referenceDate: Date

    init(
        flight: Flight,
        completion: FlightCompletionStore,
        presenter: FlightDetailPresenter = FlightDetailPresenter(),
        classifier: FlightClassifier = FlightClassifier(),
        now: @escaping @Sendable () -> Date = { .now }
    ) {
        self.flight = flight
        self.completion = completion
        self.presenter = presenter
        self.classifier = classifier
        self.now = now
        self.referenceDate = now()
    }

    /// Invalidates date-dependent presentation after clock or environment changes.
    func refreshTime() {
        referenceDate = now()
    }

    var model: FlightDetailModel {
        presenter.make(from: flight, now: referenceDate)
    }

    var isComplete: Bool {
        completion.isComplete(flight.id)
    }

    var canToggleCompletion: Bool {
        classifier.hasDeparted(flight, now: referenceDate)
    }

    var showsTodayBadge: Bool {
        classifier.showsTodayBadge(for: flight, now: referenceDate)
    }

    /// Toggles rather than only completing, so the action is reversible if tapped by mistake.
    func toggleCompletion() {
        refreshTime()
        guard canToggleCompletion else { return }
        completion.toggle(flight.id)
    }
}
