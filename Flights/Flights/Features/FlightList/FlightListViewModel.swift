import Foundation
import Observation

/// Drives the Flights screen.
///
/// Owns loading, the Upcoming/Past selection and the mapping from domain flights to row models.
/// The view reads `rows` and `state` and renders; it makes no decisions of its own.
@Observable
@MainActor
final class FlightListViewModel {
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded
        case failed(APIError)
    }

    private(set) var state: ViewState = .idle
    var selectedCategory: FlightCategory = .upcoming

    private(set) var flights: [Flight] = []

    private let apiClient: FlightsAPIClient
    private let session: SessionStore
    private let completion: FlightCompletionStore
    private let classifier: FlightClassifier
    private let builder: FlightRowModelBuilder
    /// Injected so tests can pin "now" and previews stay deterministic.
    private let now: @Sendable () -> Date
    private(set) var referenceDate: Date
    private var latestRequestID: UUID?

    init(
        apiClient: FlightsAPIClient,
        session: SessionStore,
        completion: FlightCompletionStore,
        classifier: FlightClassifier = FlightClassifier(),
        builder: FlightRowModelBuilder = FlightRowModelBuilder(),
        now: @escaping @Sendable () -> Date = { .now }
    ) {
        self.apiClient = apiClient
        self.session = session
        self.completion = completion
        self.classifier = classifier
        self.builder = builder
        self.now = now
        self.referenceDate = now()
    }

    /// Invalidates date-dependent presentation after clock or environment changes.
    func refreshTime() {
        referenceDate = now()
    }

    /// Flights for the selected segment, ordered for display.
    var visibleFlights: [Flight] {
        classifier.flights(in: selectedCategory, from: flights, now: referenceDate)
    }

    /// Rows for the selected segment, each paired with the flight it came from so the view can
    /// route on tap without looking anything up.
    ///
    /// Computed rather than stored so a change to either the flights or the completion store
    /// re-renders the list — this is what updates a row's checkmark when the user marks a
    /// flight complete on the detail screen and comes back.
    var items: [FlightListItem] {
        let instant = referenceDate
        return visibleFlights.map { flight in
            FlightListItem(
                flight: flight,
                model: builder.make(
                    from: flight,
                    isComplete: completion.isComplete(flight.id),
                    now: instant
                )
            )
        }
    }

    /// True once loading finished successfully with nothing to show in this segment.
    var isShowingEmptyState: Bool {
        state == .loaded && visibleFlights.isEmpty
    }

    func loadIfNeeded() async {
        guard state == .idle else { return }
        await load()
    }

    /// Fetches flights. Used for first load and for pull-to-refresh.
    func load() async {
        let requestID = UUID()
        latestRequestID = requestID
        guard let token = session.token else {
            state = .failed(.sessionExpired)
            return
        }
        let previousState: ViewState = state == .loading ? .idle : state
        let sessionRevision = session.revision
        if state != .loaded {
            state = .loading
        }
        do {
            try Task.checkCancellation()
            let result = try await apiClient.flights(token: token)
            try Task.checkCancellation()
            guard latestRequestID == requestID, session.revision == sessionRevision else { return }
            refreshTime()
            flights = result
            state = .loaded
        } catch {
            guard latestRequestID == requestID, session.revision == sessionRevision else { return }
            if error is CancellationError || Task.isCancelled {
                state = previousState
                return
            }
            let apiError = APIError.from(error)
            // A rejected token means the session is over; drop it so the app returns to login
            // rather than showing an error the user cannot act on.
            if apiError == .sessionExpired {
                session.endSession()
            }
            state = .failed(apiError)
        }
    }
}
