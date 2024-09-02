//
//  RelativeConverter.swift
//
//  Created by Sun on 2021/11/29.
//

import UIKit

// MARK: - ChartRange

class ChartRange {
    // MARK: Properties

    var min: Decimal
    var max: Decimal

    // MARK: Computed Properties

    var all: [Decimal] { [min, max] }
    var minPositive: Bool { min >= 0 }
    var maxPositive: Bool { max >= 0 }

    // MARK: Lifecycle

    init(min: Decimal, max: Decimal) {
        self.min = min
        self.max = max
    }
}

// MARK: - RelativeConverter

enum RelativeConverter {
    static func ranges(
        chartData: ChartData,
        indicators: [ChartIndicator],
        showIndicators: Bool
    )
        -> [String: ChartRange] {
        var ranges = allRanges(chartData: chartData, indicators: indicators)

        // for rate and all MA indicator find extremum values
        var extremums = [Decimal]()
        if let rate = ranges[ChartData.rate] {
            extremums.append(contentsOf: rate.all)
        }

        let maIDs = indicators
            .filter { $0.abstractType == .ma }
            .map(\.json)

        if showIndicators {
            for id in maIDs {
                guard let range = ranges[id] else {
                    continue
                }
                extremums.append(contentsOf: range.all)
            }
        }
        // calculate new range
        let extremumRange = ChartRange(min: extremums.min() ?? 0, max: extremums.max() ?? 0)

        // set range for all onChart indicators and rate
        ranges[ChartData.rate] = extremumRange
        for maID in maIDs {
            ranges[maID] = extremumRange
        }

        // set ranges for volume : from 0 to max
        if let volumeRange = ranges[ChartData.volume] {
            ranges[ChartData.volume] = ChartRange(min: 0, max: volumeRange.max)
        }

        // set 0..100 for every rsi
        let rsiIDs = indicators
            .filter { $0.abstractType == .rsi }
            .map(\.json)

        let rsiRange = ChartRange(min: 0, max: 100)
        for rsiID in rsiIDs {
            ranges[rsiID] = rsiRange
        }

        // merge ranges for macd : to show all lines and zoom histogram to maximum
        let macdIDs = indicators
            .filter { $0.abstractType == .macd }
            .map(\.json)

        for id in macdIDs {
            let signalID = MacdIndicator.MacdType.signal.name(id: id)
            let macdID = MacdIndicator.MacdType.macd.name(id: id)
            let histogramID = MacdIndicator.MacdType.histogram.name(id: id)

            var extremums = ranges[signalID]?.all ?? []
            extremums.append(contentsOf: ranges[macdID]?.all ?? [])
            let histogramExtremums = ranges[histogramID]?.all ?? []

            let maxValue = extremums.map { abs($0) }.max() ?? 0
            let histogramMaxValue = histogramExtremums.map { abs($0) }.max() ?? 0

            let result = ChartRange(min: -maxValue, max: maxValue)

            ranges[signalID] = result
            ranges[macdID] = result
            ranges[histogramID] = ChartRange(min: -histogramMaxValue, max: histogramMaxValue)
        }

        return ranges
    }

    static func relative(chartData: ChartData, ranges: [String: ChartRange]) -> [String: [CGPoint]] {
        let timestampDelta = chartData.endWindow - chartData.startWindow
        guard !timestampDelta.isZero else {
            return [:]
        }
        var relativeData = [String: [CGPoint]]()

        for item in chartData.visibleItems {
            let timestamp = item.timestamp - chartData.startWindow
            let x = CGFloat(timestamp / timestampDelta)
            for (key, value) in item.indicators {
                guard let range = ranges[key] else {
                    continue
                }

                let delta = range.max - range.min

                let y = delta == 0 ? 0.5 : ((value - range.min) / delta).cgFloatValue
                let point = CGPoint(x: x, y: y)

                guard relativeData[key] != nil else {
                    var points = [CGPoint]()
                    points.append(point)

                    relativeData[key] = points
                    continue
                }

                relativeData[key]?.append(point)
            }
        }

        return relativeData
    }

    private static func allRanges(chartData: ChartData, indicators _: [ChartIndicator]) -> [String: ChartRange] {
        var ranges = [String: ChartRange]()

        let visibleItems = chartData.visibleItems
        // calculate ranges for all keys
        for item in visibleItems {
            for (key, value) in item.indicators {
                guard let range = ranges[key] else {
                    ranges[key] = ChartRange(min: value, max: value)
                    continue
                }
                if value < range.min {
                    range.min = value
                }
                if value > range.max {
                    range.max = value
                }
            }
        }

        return ranges
    }
}
