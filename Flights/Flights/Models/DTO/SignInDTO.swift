import Foundation

/// Request body for `POST /api/signIn`.
nonisolated struct SignInRequestDTO: Encodable, Sendable {
    let username: String
    let password: String
}

/// Success response for `POST /api/signIn`.
nonisolated struct SignInResponseDTO: Decodable, Sendable {
    let token: String
}

/// Error envelope returned by the service, e.g. `{"error":"Invalid credentials"}`.
nonisolated struct APIErrorDTO: Decodable, Sendable {
    let error: String
}
