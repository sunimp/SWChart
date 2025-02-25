//
//  MacdIndicator.swift
//  SWChart
//
//  Created by Sun on 2024/8/15.
//

import UIKit

// MARK: - MacdIndicator

public class MacdIndicator: ChartIndicator {
    // MARK: Nested Types

    private enum CodingKeys: String, CodingKey {
        case fast
        case long
        case signal
        case configuration
    }

    // MARK: Overridden Properties

    override public var greatestPeriod: Int {
        slow + signal
    }

    override public var category: Category {
        .oscillator
    }

    // MARK: Properties

    public let fast: Int
    public let slow: Int
    public let signal: Int
    public let configuration: Configuration

    // MARK: Lifecycle

    public init(
        id: String,
        index: Int,
        enabled: Bool,
        fast: Int,
        slow: Int,
        signal: Int,
        onChart: Bool = false,
        single: Bool = true,
        configuration: Configuration = .default
    ) {
        self.fast = fast
        self.slow = slow
        self.signal = signal
        self.configuration = configuration

        super.init(id: id, index: index, enabled: enabled, onChart: onChart, single: single)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fast = try container.decode(Int.self, forKey: .fast)
        slow = try container.decode(Int.self, forKey: .long)
        signal = try container.decode(Int.self, forKey: .signal)
        configuration = try container.decode(Configuration.self, forKey: .configuration)
        try super.init(from: decoder)
    }

    // MARK: Overridden Functions

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fast, forKey: .fast)
        try container.encode(slow, forKey: .long)
        try container.encode(signal, forKey: .signal)
        try container.encode(configuration, forKey: .configuration)
        try super.encode(to: encoder)
    }

    // MARK: Static Functions

    public static func == (lhs: MacdIndicator, rhs: MacdIndicator) -> Bool {
        lhs.id == rhs.id &&
            lhs.index == rhs.index &&
            lhs.fast == rhs.fast &&
            lhs.slow == rhs.slow &&
            lhs.signal == rhs.signal &&
            lhs.configuration == rhs.configuration
    }
}

extension MacdIndicator {
    public struct Configuration: Codable, Equatable {
        // MARK: Static Computed Properties

        public static var `default`: Configuration {
            Configuration(
                fastColor: ChartColor(.blue),
                longColor: ChartColor(.yellow),
                positiveColor: ChartColor(.green),
                negativeColor: ChartColor(.red),
                width: 1,
                signalWidth: 2
            )
        }

        // MARK: Properties

        public let fastColor: ChartColor
        public let longColor: ChartColor
        public let positiveColor: ChartColor
        public let negativeColor: ChartColor

        let width: CGFloat
        let signalWidth: CGFloat

        // MARK: Lifecycle

        public init(
            fastColor: ChartColor,
            longColor: ChartColor,
            positiveColor: ChartColor,
            negativeColor: ChartColor,
            width: CGFloat,
            signalWidth: CGFloat
        ) {
            self.fastColor = fastColor
            self.longColor = longColor
            self.positiveColor = positiveColor
            self.negativeColor = negativeColor
            self.width = width
            self.signalWidth = signalWidth
        }

        // MARK: Static Functions

        public static func == (lhs: Configuration, rhs: Configuration) -> Bool {
            lhs.fastColor.hex == rhs.fastColor.hex &&
                lhs.longColor.hex == rhs.longColor.hex &&
                lhs.positiveColor.hex == rhs.positiveColor.hex &&
                lhs.negativeColor.hex == rhs.negativeColor.hex &&
                lhs.width == rhs.width &&
                lhs.signalWidth == rhs.signalWidth
        }
    }

    public enum MacdType: String {
        case macd
        case signal
        case histogram

        // MARK: Functions

        public func name(id: String) -> String {
            [id, rawValue].joined(separator: "_")
        }
    }
}
