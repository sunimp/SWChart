import UIKit
import UIExtensions
import HsExtensions

public class ChartIndicator: Codable {
    var _class: String
    public let id: String
    public let index: Int
    public var enabled: Bool
    public let onChart: Bool
    public let single: Bool


    init(id: String, index: Int, enabled: Bool, onChart: Bool, single: Bool) {
        _class = String(describing: Self.self)
        self.id = id
        self.index = index
        self.enabled = enabled
        self.onChart = onChart
        self.single = single
    }

    public var json: String {
        (try? Self.json(from: self)) ?? _class
    }

    public var abstractType: AbstractType {
        switch _class {
        case String(describing: MaIndicator.self):
            return .ma
        case String(describing: RsiIndicator.self):
            return .rsi
        case String(describing: MacdIndicator.self):
            return .macd
        default:
            return .invalid
        }
    }

    public var greatestPeriod: Int {
        0
    }

    open var category: Category {
        fatalError("must be overridden by subclass")
    }

    static func json<T: Encodable>(from object: T) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys

        let data = try encoder.encode(object)
        return String(decoding: data, as: UTF8.self)
    }

}

extension ChartIndicator: Equatable {

    public static func ==(lhs: ChartIndicator, rhs: ChartIndicator) -> Bool {
        lhs.json == rhs.json
    }

}

extension ChartIndicator {

    public enum AbstractType: String {
        case invalid
        case ma
        case macd
        case rsi
        case precalculated
    }

    public enum Category: CaseIterable {
        case movingAverage
        case oscillator
    }

    public enum InitializeError: Error {
        case wrongIndicatorClass
    }

    public struct LineConfiguration: Codable, Equatable {
        public let color: ChartColor
        public let width: CGFloat

        public init(color: ChartColor, width: CGFloat) {
            self.color = color
            self.width = width
        }

        static public var `default`: LineConfiguration {
            LineConfiguration(color: ChartColor(.blue), width: 1)
        }

        public static func ==(lhs: LineConfiguration, rhs: LineConfiguration) -> Bool {
            lhs.color.hex == rhs.color.hex &&
                lhs.width == rhs.width
        }

    }

}
