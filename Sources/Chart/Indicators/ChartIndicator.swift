import UIKit
import UIExtensions
import HsExtensions

public class ChartIndicator: Codable {
    var _class: String = "Indicator"
    let onChart: Bool

    init(onChart: Bool) {
        _class = String(describing: Self.self)
        self.onChart = onChart
    }

    public var json: String {
        (try? Self.json(from: self)) ?? _class
    }

    var indicatorType: AbstractType {
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

    static func json<T: Encodable>(from object: T) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys

        let data = try encoder.encode(object)
        return String(decoding: data, as: UTF8.self)
    }

    static func instance<T: Decodable>(from json: String) throws -> T {
        try JSONDecoder().decode(T.self, from: json.hs.data)
    }

    public static func create(from json: String) throws -> ChartIndicator {
        let indicator: ChartIndicator = try instance(from: json)

        switch indicator._class {
        case String(describing: MaIndicator.self):
            let maIndicator: MaIndicator = try instance(from: json)
            return maIndicator
        case String(describing: RsiIndicator.self):
            let maIndicator: RsiIndicator = try instance(from: json)
            return maIndicator
        case String(describing: MacdIndicator.self):
            let maIndicator: MacdIndicator = try instance(from: json)
            return maIndicator
        default: throw InitializeError.wrongIndicatorClass
        }
    }

}

extension ChartIndicator {

    enum AbstractType: String {
        case invalid
        case ma
        case macd
        case rsi
        case precalculated
    }

    public enum InitializeError: Error {
        case wrongIndicatorClass
    }

    public struct LineConfiguration: Codable, Equatable {
        let color: Color
        let width: CGFloat

        public init(color: Color, width: CGFloat) {
            self.color = color
            self.width = width
        }

        static public var `default`: LineConfiguration {
            LineConfiguration(color: Color(.blue), width: 1)
        }

        public static func ==(lhs: LineConfiguration, rhs: LineConfiguration) -> Bool {
            lhs.color.hex == rhs.color.hex &&
                lhs.width == rhs.width
        }

    }

}
