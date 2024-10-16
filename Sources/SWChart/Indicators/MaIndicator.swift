//
//  MaIndicator.swift
//  SWChart
//
//  Created by Sun on 2024/8/15.
//

import UIKit

// MARK: - MaIndicator

public class MaIndicator: ChartIndicator {
    // MARK: Nested Types

    private enum CodingKeys: String, CodingKey {
        case period
        case type
        case configuration
        case width
    }

    // MARK: Overridden Properties

    override public var greatestPeriod: Int {
        period
    }

    override public var category: Category {
        .movingAverage
    }

    // MARK: Properties

    public let period: Int
    public let type: MaType
    public let configuration: ChartIndicator.LineConfiguration

    // MARK: Lifecycle

    public init(
        id: String,
        index: Int,
        enabled: Bool,
        period: Int,
        type: MaType,
        onChart: Bool = true,
        single: Bool = false,
        configuration: ChartIndicator.LineConfiguration = .default
    ) {
        self.period = period
        self.type = type
        self.configuration = configuration

        super.init(id: id, index: index, enabled: enabled, onChart: onChart, single: single)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        period = try container.decode(Int.self, forKey: .period)
        type = try container.decode(MaType.self, forKey: .type)
        configuration = try container.decode(ChartIndicator.LineConfiguration.self, forKey: .configuration)
        try super.init(from: decoder)
    }

    // MARK: Overridden Functions

    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(period, forKey: .period)
        try container.encode(type, forKey: .type)
        try container.encode(configuration, forKey: .configuration)
    }

    // MARK: Static Functions

    public static func == (lhs: MaIndicator, rhs: MaIndicator) -> Bool {
        lhs.id == rhs.id &&
            lhs.index == rhs.index &&
            lhs.period == rhs.period &&
            lhs.type == rhs.type &&
            lhs.configuration == rhs.configuration
    }
}

// MARK: MaIndicator.MaType

extension MaIndicator {
    public enum MaType: String, CaseIterable, Codable {
        case ema
        case sma
        case wma
    }
}
