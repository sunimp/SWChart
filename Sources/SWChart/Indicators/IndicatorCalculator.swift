//
//  IndicatorCalculator.swift
//  SWChart
//
//  Created by Sun on 2024/8/15.
//

import Foundation

// MARK: - MacdData

public struct MacdData {
    public let macd: [Decimal]
    public let signal: [Decimal]
    public let histogram: [Decimal]
}

// MARK: - IndicatorCalculator

public enum IndicatorCalculator {
    // MARK: Static Properties

    public static let maximumPeriod = 200

    // MARK: Static Functions

    public static func ma(period: Int, values: [Decimal]) throws -> [Decimal] {
        try checkValidData(period: period, valueCount: values.count)

        var result = [Decimal]()

        for i in 0 ..< (values.count - period + 1) {
            let prev = values[i ..< (i + period)].reduce(0, +) / Decimal(period)

            result.append(prev)
        }
        return result
    }

    public static func ema(period: Int, values: [Decimal]) throws -> [Decimal] {
        try checkValidData(period: period, valueCount: values.count)

        let a = 2 / (1 + Decimal(period))

        var result = [Decimal]()

        var prev = values[0 ..< period].reduce(0, +) / Decimal(period)
        result.append(prev)

        for i in period ..< values.count {
            prev = a * values[i] + (1 - a) * prev

            result.append(prev)
        }
        return result
    }

    public static func wma(period: Int, values: [Decimal]) throws -> [Decimal] {
        try checkValidData(period: period, valueCount: values.count)

        let a = Decimal(period * (period + 1) / 2)

        var result = [Decimal]()

        for i in 0 ..< (values.count - period + 1) {
            var indicator: Decimal = 0
            for j in i ..< (i + period) {
                indicator += values[j] * Decimal(j - i + 1)
            }
            indicator /= a

            result.append(indicator)
        }
        return result
    }

    public static func rsi(period: Int, values: [Decimal]) throws -> [Decimal] {
        try checkValidData(period: period, valueCount: values.count)

        let decPeriod = Decimal(period)

        var upMove = [Decimal]()
        var downMove = [Decimal]()

        for i in 1 ..< values.count {
            let change = values[i] - values[i - 1]
            upMove.append(change > 0 ? change : 0)
            downMove.append(change < 0 ? abs(change) : 0)
        }

        var emaUp = [Decimal]()
        var emaDown = [Decimal]()
        var relativeStrength = [Decimal]()
        var rsi = [Decimal]()

        var maUp: Decimal = 0
        var maDown: Decimal = 0
        var rStrength: Decimal = 0

        for i in 0 ..< upMove.count {
            let up = upMove[i]
            let down = downMove[i]

            // SMA
            if i < period {
                maUp += up
                maDown += down
                continue
            }

            if i == period {
                maUp /= decPeriod
                maDown /= decPeriod

                emaUp.append(maUp)
                emaDown.append(maDown)
                if maDown.isZero {
                    rsi.append(100)
                } else {
                    rStrength = maUp / maDown

                    relativeStrength.append(rStrength)
                    rsi.append(100 - 100 / (rStrength + 1))
                }
            }

            // EMA
            maUp = (maUp * (decPeriod - 1) + up) / decPeriod
            maDown = (maDown * (decPeriod - 1) + down) / decPeriod
            rStrength = maUp / maDown

            emaUp.append(maUp)
            emaDown.append(maDown)
            relativeStrength.append(rStrength)
            rsi.append(100 - 100 / (rStrength + 1))
        }
        return rsi
    }

    public static func macd(fast: Int, long: Int, signal: Int, values: [Decimal]) throws -> MacdData {
        let diff = long - fast
        guard diff > 0 else {
            throw IndicatorError.wrongParameters
        }

        let emaFast = try ema(period: fast, values: values)
        let emaLong = try ema(period: long, values: values)
        let macd = emaLong.enumerated().map { index, long in
            emaFast[index + diff] - long
        }
        let emaSignal = try ema(period: signal, values: macd)

        let signalDiff = macd.count - emaSignal.count
        let histogram: [Decimal]

        histogram = emaSignal.enumerated().compactMap { index, signal in
            macd[index + signalDiff] - signal
        }

        return MacdData(macd: macd, signal: emaSignal, histogram: histogram)
    }

    static func checkValidData(period: Int, valueCount: Int) throws {
        guard period > 0 else {
            throw IndicatorError.tooSmallPeriod
        }
        guard period <= maximumPeriod else {
            throw IndicatorError.tooLargePeriod
        }

        guard valueCount >= period else {
            throw IndicatorError.notEnoughData
        }
    }
}

// MARK: IndicatorCalculator.IndicatorError

extension IndicatorCalculator {
    public enum IndicatorError: Error {
        case notEnoughData
        case tooSmallPeriod
        case tooLargePeriod
        case wrongParameters
        case invalidIndicator
    }
}
