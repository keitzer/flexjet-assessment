@testable import Flights

actor CountingFlightsAPIClient: FlightsAPIClient {
    private var result: Result<[Flight], APIError>
    private(set) var requestCount = 0

    init(result: Result<[Flight], APIError>) {
        self.result = result
    }

    func setResult(_ result: Result<[Flight], APIError>) { self.result = result }
    func signIn(username: String, password: String) async throws -> String { "token" }

    func flights(token: String) async throws -> [Flight] {
        requestCount += 1
        return try result.get()
    }
}
