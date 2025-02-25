//
//  ChartIndicators.swift
//  SWChart
//
//  Created by Sun on 2024/8/15.
//

import Foundation

public struct ChartIndicators: Codable {
    // MARK: Nested Types

    enum CodingKeys: CodingKey {
        case indicators
    }

    enum ObjectTypeKey: CodingKey {
        case _class
    }

    // MARK: Properties

    public let indicators: [ChartIndicator]

    // MARK: Lifecycle

    public init(with indicators: [ChartIndicator]) {
        self.indicators = indicators
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var objectsArray = try container.nestedUnkeyedContainer(forKey: CodingKeys.indicators)
        var indicators = [ChartIndicator]()

        var array = objectsArray
        while !objectsArray.isAtEnd {
            let object = try objectsArray.nestedContainer(keyedBy: ObjectTypeKey.self)
            let _class = try object.decode(String.self, forKey: ObjectTypeKey._class)
            switch _class {
            case String(describing: MaIndicator.self):
                try indicators.append(array.decode(MaIndicator.self))
            case String(describing: RsiIndicator.self):
                try indicators.append(array.decode(RsiIndicator.self))
            case String(describing: MacdIndicator.self):
                try indicators.append(array.decode(MacdIndicator.self))
            default: ()
            }
        }
        self.indicators = indicators
    }
}
