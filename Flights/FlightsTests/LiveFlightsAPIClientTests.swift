@testable import Flights
import Foundation
import Testing

@Suite("Live API requests and responses")
struct LiveFlightsAPIClientTests {
    private func withClient(
        scenario: String,
        action: (LiveFlightsAPIClient) async throws -> Void
    ) async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        let session = URLSession(configuration: configuration)
        defer { session.invalidateAndCancel() }
        let url = try #require(URL(string: "https://flights-tests.invalid/\(scenario)"))
        try await action(LiveFlightsAPIClient(baseURL: url, session: session))
    }

    @Test("Sign-in posts the supplied credentials as JSON and returns the token")
    func signInRequest() async throws {
        try await withClient(scenario: "sign-in") { client in
            let token = try await client.signIn(username: "john", password: "12345")
            #expect(token == "test-token")
        }
        // Asserted here rather than inside the stub: expectations raised on the URL-loading thread
        // are attributed to no test and leave the run's exit status zero.
        let sent = try #require(StubURLProtocol.requests(for: "sign-in").first)
        #expect(sent.method == "POST")
        #expect(sent.path == "/sign-in/api/signIn")
        #expect(sent.header("Content-Type") == "application/json")
        #expect(sent.jsonBody == ["username": "john", "password": "12345"])
    }

    @Test("Flights uses a bearer token and maps a nullable flight number")
    func flightsRequest() async throws {
        try await withClient(scenario: "flights") { client in
            let flights = try await client.flights(token: "test-token")
            #expect(flights.map(\.id) == ["FL001"])
            #expect(flights.first?.flightNumber == nil)
            #expect(flights.first?.price == 349)
        }
        let sent = try #require(StubURLProtocol.requests(for: "flights").first)
        #expect(sent.method == "GET")
        #expect(sent.path == "/flights/api/flights")
        #expect(sent.header("Authorization") == "Bearer test-token")
        #expect(sent.body.isEmpty)
    }

    @Test("Malformed records do not discard valid siblings")
    func mixedRecords() async throws {
        try await withClient(scenario: "mixed") { client in
            let flights = try await client.flights(token: "token")
            #expect(flights.map(\.id) == ["FL001"])
        }
    }

    @Test("An empty array is a successful empty response")
    func emptyResponse() async throws {
        try await withClient(scenario: "empty") { client in
            let flights = try await client.flights(token: "token")
            #expect(flights.isEmpty)
        }
    }

    @Test("A 401 has different meanings for sign-in and authenticated requests")
    func unauthorizedResponses() async throws {
        try await withClient(scenario: "401") { client in
            await #expect(throws: APIError.invalidCredentials) {
                try await client.signIn(username: "john", password: "wrong")
            }
            await #expect(throws: APIError.sessionExpired) {
                try await client.flights(token: "expired")
            }
        }
    }

    @Test("Other HTTP failures preserve the status code", arguments: [403, 429, 500, 503])
    func serverErrors(status: Int) async throws {
        try await withClient(scenario: String(status)) { client in
            await #expect(throws: APIError.server(status: status)) {
                try await client.flights(token: "token")
            }
        }
    }

    @Test("Malformed JSON and non-array payloads fail decoding", arguments: ["invalid-json", "object"])
    func invalidPayload(scenario: String) async throws {
        try await withClient(scenario: scenario) { client in
            await #expect(throws: APIError.decoding) { try await client.flights(token: "token") }
        }
    }

    @Test("A blank token is not a successful authentication response")
    func blankToken() async throws {
        try await withClient(scenario: "blank-token") { client in
            await #expect(throws: APIError.decoding) {
                try await client.signIn(username: "john", password: "12345")
            }
        }
    }

    @Test("Connectivity failures map to the offline state")
    func offline() async throws {
        try await withClient(scenario: "offline") { client in
            await #expect(throws: APIError.offline) { try await client.flights(token: "token") }
        }
    }

    @Test("URLSession cancellation remains cancellation rather than a user-facing error")
    func cancellation() async throws {
        try await withClient(scenario: "cancelled") { client in
            await #expect(throws: CancellationError.self) { try await client.flights(token: "token") }
        }
    }
}
