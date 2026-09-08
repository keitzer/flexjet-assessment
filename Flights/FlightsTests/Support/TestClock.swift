import Foundation
import Synchronization

nonisolated final class TestClock: Sendable {
    private let instant: Mutex<Date>

    init(_ date: Date) {
        instant = Mutex(date)
    }

    func now() -> Date {
        instant.withLock { $0 }
    }

    func set(_ date: Date) {
        instant.withLock { $0 = date }
    }
}
