import UIKit

public class RsiIndicator: ChartIndicator, Equatable {
    let id: String
    let period: Int
    let color: Color
    let width: CGFloat

    private enum CodingKeys : String, CodingKey {
        case id
        case period
        case type
        case color
        case width
    }

    public init(id: String, period: Int, onChart: Bool = false, color: UIColor = .blue, width: CGFloat = 1) {
        self.id = id
        self.period = period
        self.color = Color(color)
        self.width = width

        super.init(onChart: onChart)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        period = try container.decode(Int.self, forKey: .period)
        color = try container.decode(Color.self, forKey: .color)
        width = try container.decode(CGFloat.self, forKey: .width)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(period, forKey: .period)
        try container.encode(color, forKey: .color)
        try container.encode(width, forKey: .width)
        try super.encode(to: encoder)
    }

    public static func ==(lhs: RsiIndicator, rhs: RsiIndicator) -> Bool {
        lhs.id == rhs.id &&
                lhs.period == rhs.period &&
                lhs.color.hex == rhs.color.hex &&
                lhs.width == rhs.width
    }

}
