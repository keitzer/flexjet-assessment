@testable import Flights
import Foundation
import Testing

@Suite("Transport error classification")
struct APIErrorTests {
    @Test("Connectivity errors share the recoverable offline state", arguments: [
        URLError.notConnectedToInternet, .networkConnectionLost, .dataNotAllowed,
        .timedOut, .cannotFindHost, .cannotConnectToHost
    ])
    func connectivity(code: URLError.Code) {
        #expect(APIError.from(URLError(code)) == .offline)
    }

    @Test("Unrecognized errors do not masquerade as bad credentials")
    func unknownErrors() {
        #expect(APIError.from(URLError(.badURL)) == .unknown)
        #expect(APIError.from(NSError(domain: "Test", code: 1)) == .unknown)
        let context = DecodingError.Context(codingPath: [], debugDescription: "Invalid record")
        #expect(APIError.from(DecodingError.dataCorrupted(context)) == .decoding)
    }

    @Test("Domain errors preserve their identity and have actionable descriptions", arguments: [
        APIError.invalidCredentials, .sessionExpired, .offline, .server(status: 503), .decoding, .unknown
    ])
    func domainErrors(error: APIError) throws {
        #expect(APIError.from(error) == error)
        #expect(try #require(error.errorDescription).isEmpty == false)
        #expect(APIError.server(status: 503).errorDescription?.contains("503") == true)
    }
}
