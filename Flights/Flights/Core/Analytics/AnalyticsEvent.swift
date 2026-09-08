import Foundation

nonisolated enum AnalyticsValue: Encodable, Equatable, Sendable {
    case string(String)
    case bool(Bool)
    case integer(Int)

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        case .integer(let value): try container.encode(value)
        }
    }
}

nonisolated enum AnalyticsPage: String, Encodable, Sendable {
    case login, flights, favorites, contracts, profile
    case flightDetails = "flight_details"
    case routeDetails = "route_details"
    case addFlight = "add_flight"
    case app
}

nonisolated enum AnalyticsAction: String, Sendable {
    case signIn = "sign_in"
    case signOut = "sign_out"
    case addFlight = "add_flight"
    case dismissAddFlight = "dismiss_add_flight"
    case openFlight = "open_flight"
    case openRoute = "open_route"
    case favoriteRoute = "favorite_route"
    case completeFlight = "complete_flight"
    case selectCategory = "select_category"
    case selectTab = "select_tab"
    case selectTheme = "select_theme"
    case toggleHaptics = "toggle_haptics"
    case refreshFlights = "refresh_flights"
    case retryFlights = "retry_flights"
}

nonisolated enum AnalyticsStatus: String, Sendable {
    case authentication, session, theme, haptics, category, tab
    case navigationDepth = "navigation_depth"
    case addFlightPresented = "add_flight_presented"
    case flightLoading = "flight_loading"
    case routeFavorite = "route_favorite"
    case flightCompletion = "flight_completion"
}

nonisolated struct AnalyticsEvent: Encodable, Equatable, Sendable {
    let name: String
    let page: AnalyticsPage
    let timestamp: Date
    let properties: [String: AnalyticsValue]
}
