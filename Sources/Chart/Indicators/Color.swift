import UIKit
import UIExtensions

public struct Color: Codable {
    public let value: UIColor

    enum CodingKeys: CodingKey {
        case value
    }

    public init(_ color: UIColor) {
        value = color
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let hex = try container.decode(Int.self)
        value = UIColor(hex: hex)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value.hex)
    }

    public var hex: Int {
        value.hex
    }

}

extension UIColor {

    var hex: Int {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        return Int(r * 255) << 16 | Int(g * 255) << 8 | Int(b * 255) << 0
    }

}