import Foundation

/// Injectable time source so time-dependent logic stays testable.
public protocol DateProviding: Sendable {
    func now() -> Date
}

public struct SystemDateProvider: DateProviding {
    public init() {}
    public func now() -> Date { Date() }
}

/// Deterministic provider for tests.
public struct FixedDateProvider: DateProviding {
    private let date: Date
    public init(_ date: Date) { self.date = date }
    public func now() -> Date { date }
}
