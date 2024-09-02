//
//  ChartData.swift
//
//  Created by Sun on 2021/11/29.
//

import Foundation

public class ChartData {
    // MARK: Static Properties

    public static let rate = "rate"
    public static let volume = "volume"

    // MARK: Properties

    public var items: [ChartItem]
    public var startWindow: TimeInterval
    public var endWindow: TimeInterval

    // MARK: Computed Properties

    public var visibleItems: [ChartItem] {
        items.filter { item in item.timestamp >= startWindow && item.timestamp <= endWindow }
    }

    // MARK: Lifecycle

    public init(items: [ChartItem], startWindow: TimeInterval, endWindow: TimeInterval) {
        self.items = items
        self.startWindow = startWindow
        self.endWindow = endWindow
    }

    // MARK: Functions

    public func add(name: String, values: [Decimal]) {
        let start = items.count - values.count

        for i in 0 ..< values.count {
            items[i + start].added(name: name, value: values[i])
        }
    }

    public func append(indicators: [String: [Decimal]]) {
        for (key, values) in indicators {
            add(name: key, values: values)
        }
    }

    public func insert(item: ChartItem) {
        guard !items.isEmpty else {
            items.append(item)
            return
        }
        let index = items.firstIndex { $0.timestamp >= item.timestamp } ?? items.count
        if items[index] == item {
            items.remove(at: index)
        }
        items.insert(item, at: index)
    }

    public func removeIndicator(id: String) {
        for item in items {
            item.indicators[id] = nil
        }
    }

    public func values(name: String) -> [Decimal] {
        items.compactMap { $0.indicators[name] }
    }

    public func last(name: String) -> Decimal? {
        items.last?.indicators[name]
    }
}
