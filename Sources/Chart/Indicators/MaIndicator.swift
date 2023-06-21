import UIKit

public class MaIndicator: ChartIndicator, Equatable {
    let id: String
    let period: Int
    let type: MaType
    let configuration: ChartIndicator.LineConfiguration

    private enum CodingKeys : String, CodingKey {
        case id
        case period
        case type
        case configuration
        case width
    }

    public init(id: String, period: Int, type: MaType, onChart: Bool = true, configuration: ChartIndicator.LineConfiguration = .default) {
        self.id = id
        self.period = period
        self.type = type
        self.configuration = configuration

        super.init(onChart: onChart)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        period = try container.decode(Int.self, forKey: .period)
        type = try container.decode(MaType.self, forKey: .type)
        configuration = try container.decode(ChartIndicator.LineConfiguration.self, forKey: .configuration)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(period, forKey: .period)
        try container.encode(type, forKey: .type)
        try container.encode(configuration, forKey: .configuration)
        try super.encode(to: encoder)
    }

    public static func ==(lhs: MaIndicator, rhs: MaIndicator) -> Bool {
        lhs.id == rhs.id &&
                lhs.period == rhs.period &&
                lhs.type == rhs.type &&
                lhs.configuration == rhs.configuration
    }

}

extension MaIndicator {

    public enum MaType: String, Codable {
        case ema
        case sma
        case wma
    }

}
