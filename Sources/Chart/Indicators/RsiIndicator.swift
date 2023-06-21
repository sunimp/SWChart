import UIKit

public class RsiIndicator: ChartIndicator, Equatable {
    let id: String
    let period: Int
    let configuration: ChartIndicator.LineConfiguration

    private enum CodingKeys : String, CodingKey {
        case id
        case period
        case type
        case configuration
    }

    public init(id: String, period: Int, onChart: Bool = false, configuration: ChartIndicator.LineConfiguration = .default) {
        self.id = id
        self.period = period
        self.configuration = configuration

        super.init(onChart: onChart)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        period = try container.decode(Int.self, forKey: .period)
        configuration = try container.decode(ChartIndicator.LineConfiguration.self, forKey: .configuration)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(period, forKey: .period)
        try container.encode(configuration, forKey: .configuration)
        try super.encode(to: encoder)
    }

    public static func ==(lhs: RsiIndicator, rhs: RsiIndicator) -> Bool {
        lhs.id == rhs.id &&
                lhs.period == rhs.period &&
                lhs.configuration == rhs.configuration
    }

}
