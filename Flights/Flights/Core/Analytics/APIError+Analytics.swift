extension APIError {
    /// Stable failure categories, not localized messages or raw transport payloads.
    var analyticsCode: String {
        switch self {
        case .invalidCredentials: "invalid_credentials"
        case .sessionExpired: "session_expired"
        case .offline: "offline"
        case .server: "server"
        case .decoding: "decoding"
        case .unknown: "unknown"
        }
    }
}
