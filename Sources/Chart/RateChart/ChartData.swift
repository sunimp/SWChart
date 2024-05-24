import Foundation

public class ChartData {
    public static let rate = "rate"
    public static let volume = "volume"

    public var items: [ChartItem]
    public var startWindow: TimeInterval
    public var endWindow: TimeInterval

    public init(items: [ChartItem], startWindow: TimeInterval, endWindow: TimeInterval) {
        self.items = items
        self.startWindow = startWindow
        self.endWindow = endWindow
    }

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

    public var visibleItems: [ChartItem] {
        items.filter { item in item.timestamp >= startWindow && item.timestamp <= endWindow }
    }

    public func last(name: String) -> Decimal? {
        items.last?.indicators[name]
    }
}
