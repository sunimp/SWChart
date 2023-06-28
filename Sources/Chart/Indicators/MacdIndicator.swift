import UIKit

public class MacdIndicator: ChartIndicator {
    let fast: Int
    let long: Int
    let signal: Int
    let configuration: Configuration

    private enum CodingKeys : String, CodingKey {
        case fast
        case long
        case signal
        case configuration
    }

    public init(id: String, index: Int, enabled: Bool, fast: Int, long: Int, signal: Int, onChart: Bool = false, configuration: Configuration = .default) {
        self.fast = fast
        self.long = long
        self.signal = signal
        self.configuration = configuration

        super.init(id: id, index: index, enabled: enabled, onChart: onChart)
    }

    override public var greatestPeriod: Int {
        max(fast, long, signal)
    }

    public override var category: Category {
        .oscillator
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fast = try container.decode(Int.self, forKey: .fast)
        long = try container.decode(Int.self, forKey: .long)
        signal = try container.decode(Int.self, forKey: .signal)
        configuration = try container.decode(Configuration.self, forKey: .configuration)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fast, forKey: .fast)
        try container.encode(long, forKey: .long)
        try container.encode(signal, forKey: .signal)
        try container.encode(configuration, forKey: .configuration)
        try super.encode(to: encoder)
    }

    public static func ==(lhs: MacdIndicator, rhs: MacdIndicator) -> Bool {
        lhs.id == rhs.id &&
                lhs.index == rhs.index &&
                lhs.fast == rhs.fast &&
                lhs.long == rhs.long &&
                lhs.signal == rhs.signal &&
                lhs.configuration == rhs.configuration
    }

}

extension MacdIndicator {

    public struct Configuration: Codable, Equatable {
        let fastColor: ChartColor
        let longColor: ChartColor
        let positiveColor: ChartColor
        let negativeColor: ChartColor
        let width: CGFloat
        let signalWidth: CGFloat

        static public var `default`: Configuration {
            Configuration(fastColor: ChartColor(.blue), longColor: ChartColor(.yellow), positiveColor: ChartColor(.green), negativeColor: ChartColor(.red), width: 1, signalWidth: 2)
        }

        public init(fastColor: ChartColor, longColor: ChartColor, positiveColor: ChartColor, negativeColor: ChartColor, width: CGFloat, signalWidth: CGFloat) {
            self.fastColor = fastColor
            self.longColor = longColor
            self.positiveColor = positiveColor
            self.negativeColor = negativeColor
            self.width = width
            self.signalWidth = signalWidth
        }

        public static func ==(lhs: Configuration, rhs: Configuration) -> Bool {
            lhs.fastColor.hex == rhs.fastColor.hex &&
                    lhs.longColor.hex == rhs.longColor.hex &&
                    lhs.positiveColor.hex == rhs.positiveColor.hex &&
                    lhs.negativeColor.hex == rhs.negativeColor.hex &&
                    lhs.width == rhs.width &&
                    lhs.signalWidth == rhs.signalWidth
        }
    }

    public enum MacdType: String {
        case macd = "macd"
        case signal = "signal"
        case histogram = "histogram"

        func name(id: String) -> String {
            [id, rawValue].joined(separator: "_")
        }
    }

}