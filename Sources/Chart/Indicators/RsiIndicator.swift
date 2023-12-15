import UIKit

public class RsiIndicator: ChartIndicator {
    public let period: Int
    public let configuration: ChartIndicator.LineConfiguration

    private enum CodingKeys: String, CodingKey {
        case period
        case type
        case configuration
    }

    public init(id: String, index: Int, enabled: Bool, period: Int, onChart: Bool = false, single: Bool = true, configuration: ChartIndicator.LineConfiguration = .default) {
        self.period = period
        self.configuration = configuration

        super.init(id: id, index: index, enabled: enabled, onChart: onChart, single: single)
    }

    override public var greatestPeriod: Int {
        period
    }

    override public var category: Category {
        .oscillator
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        period = try container.decode(Int.self, forKey: .period)
        configuration = try container.decode(ChartIndicator.LineConfiguration.self, forKey: .configuration)
        try super.init(from: decoder)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(period, forKey: .period)
        try container.encode(configuration, forKey: .configuration)
        try super.encode(to: encoder)
    }

    public static func == (lhs: RsiIndicator, rhs: RsiIndicator) -> Bool {
        lhs.id == rhs.id &&
            lhs.index == rhs.index &&
            lhs.period == rhs.period &&
            lhs.configuration == rhs.configuration
    }
}
