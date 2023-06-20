import UIKit

public class PrecalculatedIndicator: ChartIndicator, Equatable {
    let id: String
    let values: [Decimal]
    let color: Color
    let width: CGFloat

    public init(id: String, values: [Decimal], onChart: Bool = true, color: UIColor = .blue, width: CGFloat = 1) {
        self.id = id
        self.values = values
        self.color = Color(color)
        self.width = width

        super.init(onChart: onChart)
    }

    private enum CodingKeys : String, CodingKey {
        case id
        case color
        case width
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        color = try container.decode(Color.self, forKey: .color)
        width = try container.decode(CGFloat.self, forKey: .width)

        values = []
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(color, forKey: .color)
        try container.encode(width, forKey: .width)
        try super.encode(to: encoder)
    }

    public static func ==(lhs: PrecalculatedIndicator, rhs: PrecalculatedIndicator) -> Bool {
        lhs.id == rhs.id &&
                lhs.values == rhs.values &&
                lhs.onChart == rhs.onChart &&
                lhs.color.hex == rhs.color.hex &&
                lhs.width == rhs.width
    }

}
