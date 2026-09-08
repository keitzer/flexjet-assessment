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
    }

    var model: FlightDetailModel {
        presenter.make(from: flight, now: now())
    }

    var isComplete: Bool {
        completion.isComplete(flight.id)
    }

    var canToggleCompletion: Bool {
        classifier.hasDeparted(flight, now: now())
    }

    var showsTodayBadge: Bool {
        classifier.showsTodayBadge(for: flight, now: now())
    }

    /// Toggles rather than only completing, so the action is reversible if tapped by mistake.
    func toggleCompletion() {
        guard canToggleCompletion else { return }
        completion.toggle(flight.id)
    }
}
