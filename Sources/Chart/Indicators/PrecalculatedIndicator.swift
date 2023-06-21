import UIKit

public class PrecalculatedIndicator: ChartIndicator, Equatable {
    let id: String
    let values: [Decimal]
    let configuration: ChartIndicator.LineConfiguration

    public init(id: String, values: [Decimal], onChart: Bool = true, configuration: ChartIndicator.LineConfiguration = .default) {
        self.id = id
        self.values = values
        self.configuration = configuration

        super.init(onChart: onChart)
    }

    private enum CodingKeys : String, CodingKey {
        case id
        case configuration
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        configuration = try container.decode(ChartIndicator.LineConfiguration.self, forKey: .configuration)

        values = []
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(configuration, forKey: .configuration)
        try super.encode(to: encoder)
    }

    public static func ==(lhs: PrecalculatedIndicator, rhs: PrecalculatedIndicator) -> Bool {
        lhs.id == rhs.id &&
                lhs.values == rhs.values &&
                lhs.onChart == rhs.onChart &&
                lhs.configuration == rhs.configuration
    }

}
