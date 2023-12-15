import Foundation

public class ChartItem: Comparable {
    public var indicators = [String: Decimal]()

    public let timestamp: TimeInterval

    public init(timestamp: TimeInterval) {
        self.timestamp = timestamp
    }

    @discardableResult public func added(name: String, value: Decimal) -> Self {
        indicators[name] = value

        return self
    }

    public static func < (lhs: ChartItem, rhs: ChartItem) -> Bool {
        lhs.timestamp < rhs.timestamp
    }

    public static func == (lhs: ChartItem, rhs: ChartItem) -> Bool {
        lhs.timestamp == rhs.timestamp
    }
}
