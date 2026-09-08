import Foundation
import Synchronization

/// A request as it reached the transport layer.
///
/// Captured so tests can assert on request construction from the test body. Expectations evaluated
/// inside `URLProtocol.startLoading()` run outside any test's task context: Swift Testing records
/// them against `Test «unknown»` and `xcodebuild` still exits zero, so a regression there would
/// never fail CI. Capturing here and asserting later keeps those checks enforceable.
nonisolated struct CapturedRequest: Sendable {
    let method: String?
    let path: String?
    let headers: [String: String]
    let body: Data

    func header(_ name: String) -> String? {
        headers.first { $0.key.caseInsensitiveCompare(name) == .orderedSame }?.value
    }

    /// The JSON body decoded as a flat string dictionary, which is all this service sends.
    var jsonBody: [String: String]? {
        try? JSONDecoder().decode([String: String].self, from: body)
    }
}

/// Stateless responses selected by URL path keep parallel tests independent without global handlers.
nonisolated final class StubURLProtocol: URLProtocol {
    static let flightJSON = """
    {"id":"FL001","tripNumber":"1234567","flightNumber":null,"tailNumber":"N987UA",
    "origin":"Las Vegas (LAS)","originIata":"LAS","destination":"New York (JFK)",
    "destinationIata":"JFK","departure":"2026-09-05T12:00:00Z",
    "arrival":"2026-09-05T18:00:00Z","price":349}
    """

    private static let capturedByScenario = Mutex<[String: [CapturedRequest]]>([:])

    /// Requests the stub saw for a scenario, in the order they arrived.
    static func requests(for scenario: String) -> [CapturedRequest] {
        capturedByScenario.withLock { $0[scenario] ?? [] }
    }

    override static func canInit(with request: URLRequest) -> Bool { true }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let url = request.url else { return }
        let scenario = url.pathComponents.dropFirst().first ?? ""
        Self.capture(request, scenario: scenario)
        if scenario == "offline" || scenario == "cancelled" {
            let code: URLError.Code = scenario == "offline" ? .notConnectedToInternet : .cancelled
            client?.urlProtocol(self, didFailWithError: URLError(code))
            return
        }
        let status = Int(scenario) ?? 200
        guard let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil) else {
            return
        }
        let body = Self.responseBody(for: scenario)
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data(body.utf8))
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}

    private static func capture(_ request: URLRequest, scenario: String) {
        let entry = CapturedRequest(
            method: request.httpMethod,
            path: request.url?.path,
            headers: request.allHTTPHeaderFields ?? [:],
            body: body(of: request)
        )
        capturedByScenario.withLock { $0[scenario, default: []].append(entry) }
    }

    private static func responseBody(for scenario: String) -> String {
        switch scenario {
        case "sign-in": "{\"token\":\"test-token\"}"
        case "flights": "[\(flightJSON)]"
        case "mixed": "[null, 42, {\"price\":\"wrong-type\"}, \(flightJSON)]"
        case "empty": "[]"
        case "blank-token": "{\"token\":\"   \"}"
        case "invalid-json": "[broken"
        default: "{}"
        }
    }

    /// URLSession converts `httpBody` to a stream before a protocol sees it, so read either form.
    private static func body(of request: URLRequest) -> Data {
        if let body = request.httpBody { return body }
        guard let stream = request.httpBodyStream else { return Data() }
        stream.open()
        defer { stream.close() }
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 1024)
        while stream.hasBytesAvailable {
            let count = stream.read(&buffer, maxLength: buffer.count)
            guard count > 0 else { break }
            data.append(contentsOf: buffer.prefix(count))
        }
        return data
    }
}
