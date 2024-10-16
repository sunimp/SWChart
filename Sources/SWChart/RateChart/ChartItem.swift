//
//  ChartItem.swift
//  SWChart
//
//  Created by Sun on 2024/8/15.
//

import Foundation

public class ChartItem: Comparable {
    // MARK: Properties

    public var indicators = [String: Decimal]()

    public let timestamp: TimeInterval

    // MARK: Lifecycle

    public init(timestamp: TimeInterval) {
        self.timestamp = timestamp
    }

    // MARK: Static Functions

    public static func < (lhs: ChartItem, rhs: ChartItem) -> Bool {
        lhs.timestamp < rhs.timestamp
    }

    public static func == (lhs: ChartItem, rhs: ChartItem) -> Bool {
        lhs.timestamp == rhs.timestamp
    }

    // MARK: Functions

    @discardableResult
    public func added(name: String, value: Decimal) -> Self {
        indicators[name] = value

        return self
    }
}
