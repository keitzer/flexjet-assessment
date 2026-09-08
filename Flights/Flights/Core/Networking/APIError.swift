import Foundation

/// Every failure the app can surface from the flights service.
///
/// Transport and status-code details are collapsed into a small set of cases the UI can react to,
/// so views never inspect `URLError` codes or HTTP numbers themselves.
nonisolated enum APIError: Error, Equatable, Sendable {
    /// 401 from `signIn` — the username/password pair was rejected.
    case invalidCredentials
    /// 401 from an authenticated route — the token is missing, expired or malformed.
    case sessionExpired
    /// The device could not reach the service at all.
    case offline
    /// A non-success status the app has no specific handling for.
    case server(status: Int)
    /// The response body did not match the documented shape.
    case decoding
    /// Anything else, including cancellation-adjacent transport errors.
    case unknown
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            "That username and password don't match. Please try again."
        case .sessionExpired:
            "Your session has expired. Please sign in again."
        case .offline:
            "You appear to be offline. Check your connection and try again."
        case .server(let status):
            "The flights service is unavailable right now (error \(status)). Please try again."
        case .decoding:
            "We received an unexpected response from the flights service."
        case .unknown:
            "Something went wrong. Please try again."
        }
    }

    /// Maps a transport-level error onto the app's vocabulary.
    static func from(_ error: Error) -> APIError {
        if let apiError = error as? Self {
            return apiError
        }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
                return .offline
            case .timedOut, .cannotFindHost, .cannotConnectToHost:
                return .offline
            default:
                return .unknown
            }
        }
        if error is DecodingError {
            return .decoding
        }
        return .unknown
    }
}
