//
//  ChartColor.swift
//  SWChart
//
//  Created by Sun on 2024/8/15.
//

import UIKit

import UIExtensions

// MARK: - ChartColor

public struct ChartColor: Codable {
    // MARK: Nested Types

    enum CodingKeys: CodingKey {
        case value
    }

    // MARK: Properties

    public let value: UIColor

    // MARK: Computed Properties

    public var hex: Int {
        value.hex
    }

    // MARK: Lifecycle

    public init(_ color: UIColor) {
        value = color
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let hexa = try container.decode(Int.self)
        value = UIColor(hexa: hexa)
    }

    // MARK: Functions

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value.hex)
    }
}

extension UIColor {
    var hex: Int {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        return Int(r * 255) << 24 | Int(g * 255) << 16 | Int(b * 255) << 8 | Int(a * 255) << 0
    }

    public convenience init(hexa: Int) {
        self.init(
            red: CGFloat((hexa >> 24) & 0xFF) / 255,
            green: CGFloat((hexa >> 16) & 0xFF) / 255,
            blue: CGFloat((hexa >> 8) & 0xFF) / 255,
            alpha: CGFloat(hexa & 0xFF) / 255
        )
    }
}
