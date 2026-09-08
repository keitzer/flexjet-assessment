@testable import Flights
import Foundation
import Testing

@Suite("Flight decoding cancellation")
struct FlightDecodingCancellationTests {
    @Test("Record decoding exits with cancellation instead of returning a partial result")
    func stopsCancelledDecoding() async {
        let task = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            do {
                _ = try JSONDecoder().decode(FlightsResponseDTO.self, from: Data("[{}]".utf8))
                return false
            } catch is CancellationError {
                return true
            } catch {
                return false
            }
        }
        #expect(await task.value)
    }
}
