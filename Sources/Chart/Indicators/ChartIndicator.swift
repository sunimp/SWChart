//
//  ChartIndicator.swift
//
//  Created by Sun on 2023/6/20.
//

import UIKit

import UIExtensions
import WWExtensions

// MARK: - ChartIndicator

public class ChartIndicator: Codable {
    // MARK: Properties

    public let id: String
    public let index: Int
    public var enabled: Bool
    public let onChart: Bool
    public let single: Bool

    var _class: String

    // MARK: Computed Properties

    open var category: Category {
        fatalError("must be overridden by subclass")
    }

    public var json: String {
        (try? Self.json(from: self)) ?? _class
    }

    public var abstractType: AbstractType {
        switch _class {
        case String(describing: MaIndicator.self):
            .ma
        case String(describing: RsiIndicator.self):
            .rsi
        case String(describing: MacdIndicator.self):
            .macd
        default:
            .invalid
        }
    }

    public var greatestPeriod: Int {
        0
    }

    // MARK: Lifecycle

    init(id: String, index: Int, enabled: Bool, onChart: Bool, single: Bool) {
        _class = String(describing: Self.self)
        self.id = id
        self.index = index
        self.enabled = enabled
        self.onChart = onChart
        self.single = single
    }

    // MARK: Static Functions

    static func json(from object: some Encodable) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys

        let data = try encoder.encode(object)
        return String(decoding: data, as: UTF8.self)
    }
}

// MARK: Equatable

extension ChartIndicator: Equatable {
    public static func == (lhs: ChartIndicator, rhs: ChartIndicator) -> Bool {
        lhs.json == rhs.json
    }
}

extension ChartIndicator {
    public enum AbstractType: String {
        case invalid
        case ma
        case macd
        case rsi
        case precalculated
    }

    public enum Category: CaseIterable {
        case movingAverage
        case oscillator
    }

    public enum InitializeError: Error {
        case wrongIndicatorClass
    }

    public struct LineConfiguration: Codable, Equatable {
        // MARK: Static Computed Properties

        public static var `default`: LineConfiguration {
            LineConfiguration(color: ChartColor(.blue), width: 1)
        }

        // MARK: Properties

        public let color: ChartColor
        public let width: CGFloat

        // MARK: Lifecycle

        public init(color: ChartColor, width: CGFloat) {
            self.color = color
            self.width = width
        }

        // MARK: Static Functions

        public static func == (lhs: LineConfiguration, rhs: LineConfiguration) -> Bool {
            lhs.color.hex == rhs.color.hex &&
                lhs.width == rhs.width
        }
    }
}
