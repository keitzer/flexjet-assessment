import Foundation

/// Static configuration for the flights service.
nonisolated enum APIConfiguration {
    /// Root URL of the service. Validated once at first use; the string is a compile-time
    /// constant, so a failure here is a programmer error rather than a runtime condition.
    static let baseURL: URL = {
        guard let url = URL(string: "https://v0-simple-authentication-api.vercel.app") else {
            preconditionFailure("The hard-coded API base URL is malformed.")
        }
        return url
    }()
}
