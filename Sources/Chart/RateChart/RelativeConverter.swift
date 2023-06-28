import UIKit

private class ChartRange {
    var min: Decimal
    var max: Decimal

    init(min: Decimal, max: Decimal) {
        self.min = min
        self.max = max
    }

    var all: [Decimal] { [min, max] }
}

class RelativeConverter {

    private static func allRanges(chartData: ChartData, indicators: [ChartIndicator]) -> [String: ChartRange] {
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

    static private func ranges(chartData: ChartData, indicators: [ChartIndicator]) -> [String: ChartRange] {
        var ranges = allRanges(chartData: chartData, indicators: indicators)

        // for rate and all MA indicator find extremum values
        var extremums = [Decimal]()
        if let rate = ranges[ChartData.rate] {
            extremums.append(contentsOf: rate.all)
        }

        let maIds = indicators
                .filter { $0.abstractType == .ma }
                .map { $0.json }

        for id in maIds {
            guard let range = ranges[id] else {
                continue
            }
            extremums.append(contentsOf: range.all)
        }
        // calculate new range
        let extremumRange = ChartRange(min: extremums.min() ?? 0, max: extremums.max() ?? 0)

        // set range for all onChart indicators and rate
        ranges[ChartData.rate] = extremumRange
        maIds.forEach { ranges[$0] = extremumRange }

        // set ranges for volume : from 0 to max
        if let volumeRange = ranges[ChartData.volume] {
            ranges[ChartData.volume] = ChartRange(min: 0, max: volumeRange.max)
        }

        // set 0..100 for every rsi
        let rsiIds = indicators
                .filter { $0.abstractType == .rsi }
                .map { $0.json }

        let rsiRange = ChartRange(min: 0, max: 100)
        rsiIds.forEach { ranges[$0] = rsiRange }

        // merge ranges for macd : to show all lines and zoom histogram to maximum
        let macdIds = indicators
                .filter { $0.abstractType == .macd }
                .map { $0.json }

        for id in macdIds {
            let signal = MacdIndicator.MacdType.signal.name(id: id)
            let macdId = MacdIndicator.MacdType.macd.name(id: id)

            var extremums = ranges[signal]?.all ?? []
            extremums.append(contentsOf: ranges[macdId]?.all ?? [])
            let maxValue = extremums.map { abs($0) }.max() ?? 0

            let result = ChartRange(min: -maxValue, max: maxValue)

            ranges[signal] = result
            ranges[macdId] = result
        }

        return ranges
    }

    static private func relative(chartData: ChartData, ranges: [String: ChartRange]) -> [String: [CGPoint]] {
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

    static func convert(chartData: ChartData, indicators: [ChartIndicator]) -> [String: [CGPoint]] {

        // calculate ranges for all data
        let indicatorRanges = ranges(chartData: chartData, indicators: indicators)
        // make relative points
        return relative(chartData: chartData, ranges: indicatorRanges)
    }

}
