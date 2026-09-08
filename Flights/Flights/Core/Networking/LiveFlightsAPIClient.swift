import Foundation

/// `URLSession`-backed implementation of `FlightsAPIClient`.
///
/// Deliberately small: two endpoints, one request builder, one response validator. There is no
/// third-party networking dependency because the surface does not justify one.
nonisolated struct LiveFlightsAPIClient: FlightsAPIClient {
    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL = APIConfiguration.baseURL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    @concurrent
    func signIn(username: String, password: String) async throws -> String {
        var request = URLRequest(url: baseURL.appending(path: "api/signIn"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            SignInRequestDTO(username: username, password: password)
        )
        let data = try await perform(request, unauthorizedError: .invalidCredentials)
        let token = try decode(SignInResponseDTO.self, from: data).token
        guard !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw APIError.decoding
        }
        return token
    }

    @concurrent
    func flights(token: String) async throws -> [Flight] {
        var request = URLRequest(url: baseURL.appending(path: "api/flights"))
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let data = try await perform(request, unauthorizedError: .sessionExpired)
        // Records that fail validation are dropped rather than failing the whole screen, so one
        // malformed flight cannot leave the user with an empty list.
        return try decode(FlightsResponseDTO.self, from: data).flights
    }

    /// Sends a request and validates the status code.
    /// - Parameter unauthorizedError: which error a 401 means for this particular endpoint.
    private func perform(_ request: URLRequest, unauthorizedError: APIError) async throws -> Data {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            if error is CancellationError || (error as? URLError)?.code == .cancelled {
                throw CancellationError()
            }
            throw APIError.from(error)
        }
        guard let http = response as? HTTPURLResponse else {
            throw APIError.unknown
        }
        switch http.statusCode {
        case 200..<300:
            return data
        case 401:
            throw unauthorizedError
        default:
            throw APIError.server(status: http.statusCode)
        }
    }

    private func decode<Value: Decodable>(_ type: Value.Type, from data: Data) throws -> Value {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw APIError.decoding
        }
    }
}
