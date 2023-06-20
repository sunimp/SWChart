import UIKit

public class MacdIndicator: ChartIndicator, Equatable {
    let id: String
    let fast: Int
    let long: Int
    let signal: Int
    let configuration: Configuration

    private enum CodingKeys : String, CodingKey {
        case id
        case fast
        case long
        case signal
        case configuration
    }

    public init(id: String, fast: Int, long: Int, signal: Int, onChart: Bool = false, configuration: Configuration = .default) {
        self.id = id
        self.fast = fast
        self.long = long
        self.signal = signal
        self.configuration = configuration

        super.init(onChart: onChart)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        fast = try container.decode(Int.self, forKey: .fast)
        long = try container.decode(Int.self, forKey: .long)
        signal = try container.decode(Int.self, forKey: .signal)
        configuration = try container.decode(Configuration.self, forKey: .configuration)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(fast, forKey: .fast)
        try container.encode(long, forKey: .long)
        try container.encode(signal, forKey: .signal)
        try container.encode(configuration, forKey: .configuration)
        try super.encode(to: encoder)
    }

    public static func ==(lhs: MacdIndicator, rhs: MacdIndicator) -> Bool {
        lhs.id == rhs.id &&
                lhs.fast == rhs.fast &&
                lhs.long == rhs.long &&
                lhs.signal == rhs.signal &&
                lhs.configuration == rhs.configuration
    }

}

extension MacdIndicator {

    public struct Configuration: Codable, Equatable {
        let fastColor: Color
        let longColor: Color
        let positiveColor: Color
        let negativeColor: Color
        let width: CGFloat
        let signalWidth: CGFloat

        static public var `default`: Configuration {
            Configuration(fastColor: Color(.blue), longColor: Color(.yellow), positiveColor: Color(.green), negativeColor: Color(.red), width: 1, signalWidth: 2)
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

}