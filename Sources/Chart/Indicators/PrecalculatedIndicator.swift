import UIKit

public class PrecalculatedIndicator: ChartIndicator {
    let values: [Decimal]
    let configuration: ChartIndicator.LineConfiguration

    public init(id: String, index: Int = 0, enabled: Bool, values: [Decimal], onChart: Bool = true, single: Bool = false, configuration: ChartIndicator.LineConfiguration = .default) {
        self.values = values
        self.configuration = configuration

        super.init(id: id, index: index, enabled: enabled, onChart: onChart, single: single)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case configuration
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        configuration = try container.decode(ChartIndicator.LineConfiguration.self, forKey: .configuration)

        values = []
        try super.init(from: decoder)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(configuration, forKey: .configuration)
        try super.encode(to: encoder)
    }

    public static func == (lhs: PrecalculatedIndicator, rhs: PrecalculatedIndicator) -> Bool {
        lhs.id == rhs.id &&
            lhs.index == rhs.index &&
            lhs.values == rhs.values &&
            lhs.onChart == rhs.onChart &&
            lhs.configuration == rhs.configuration
    }
}
