import Foundation

public enum ChartIndicatorType {
    case ma(id: String, period: Int, type: MaType)
    case macd(id: String, fast: Int, long: Int, signal: Int)
    case rsi(id: String, period: Int)

    var id: String {
        switch self {
        case .ma(let id, _, _), .macd(let id, _, _, _), .rsi(let id, _): return id
        }
    }

    var abstract: Abstract {
        switch self {
        case .ma: return .ma
        case .macd: return .macd
        case .rsi: return .rsi
        }
    }

    var name: String {
        [abstract.rawValue, id].joined(separator: "_")
    }

    enum Abstract: String {
        case ma
        case macd
        case rsi
    }

    public enum MaType {
        case sma
        case ema
        case wma
    }

    public enum MacdType: String {
        case macd = "macd"
        case signal = "signal"
        case histogram = "histogram"

        func name(id: String) -> String {
            [id, rawValue].joined(separator: "_")
        }
    }

}

public protocol IIndicatorFactory {
    func indicatorData(type: ChartIndicatorType, values: [Decimal]) throws -> [String: [Decimal]]
    func indicatorLast(type: ChartIndicatorType, values: [Decimal]) throws -> [String: Decimal]
}

public class IndicatorFactory: IIndicatorFactory {

    public func store(indicators: [ChartIndicator], chartData: ChartData) throws {
        // 1. get all rates to calculate indicators
        let rates = chartData.values(name: ChartData.rate)

        for indicator in indicators {
            let indicatorName = indicator.json
            switch indicator {
            case let indicator as PrecalculatedIndicator:
                // just add values by id
                chartData.add(name: indicatorName, values: indicator.values)
            case let indicator as MaIndicator:
                // calculate data
                let values: [Decimal]
                switch indicator.type {
                case .ema: values = try ChartIndicators.ema(period: indicator.period, values: rates)
                case .sma: values = try ChartIndicators.ma(period: indicator.period, values: rates)
                case .wma: values = try ChartIndicators.wma(period: indicator.period, values: rates)
                }
                chartData.add(name: indicatorName, values: values)
            case let indicator as RsiIndicator:
                // calculate data
                let values = try ChartIndicators.rsi(period: indicator.period, values: rates)
                chartData.add(name: indicatorName, values: values)
            case let indicator as MacdIndicator:
                // calculate data
                let values = try ChartIndicators.macd(fast: indicator.fast, long: indicator.long, signal: indicator.signal, values: rates)
                // todo: remove or replace ChartIndicatorType.MacdType.macd.name(id: indicatorName)
                chartData.add(name: ChartIndicatorType.MacdType.macd.name(id: indicatorName), values: values.macd)
                chartData.add(name: ChartIndicatorType.MacdType.signal.name(id: indicatorName), values: values.signal)
                chartData.add(name: ChartIndicatorType.MacdType.histogram.name(id: indicatorName), values: values.histogram)
            default: throw CancellationError()
            }
        }
    }

    public func indicatorData(type: ChartIndicatorType, values: [Decimal]) throws -> [String: [Decimal]] {
        var data = [String: [Decimal]]()

        switch type {
        case let .ma(_, period, maType):
            switch maType {
            case .ema: data[type.name] = try ChartIndicators.ema(period: period, values: values)
            case .sma: data[type.name] = try ChartIndicators.ma(period: period, values: values)
            case .wma: data[type.name] = try ChartIndicators.wma(period: period, values: values)
            }
        case let .macd(id, fast, long, signal):
            let macd = try ChartIndicators.macd(fast: fast, long: long, signal: signal, values: values)
            data[ChartIndicatorType.MacdType.macd.name(id: id)] = macd.macd
            data[ChartIndicatorType.MacdType.signal.name(id: id)] = macd.signal
            data[ChartIndicatorType.MacdType.histogram.name(id: id)] = macd.histogram
        case .rsi(_, let period):
            data[type.name] = try ChartIndicators.rsi(period: period, values: values)
        }

        return data
    }

    public func indicatorLast(type: ChartIndicatorType, values: [Decimal]) throws -> [String: Decimal] {
        let data = try indicatorData(type: type, values: values)
        var last = [String: Decimal]()

        data.forEach { key, values in
            if let lastValue = values.last {
                last[key] = lastValue
            }
        }

        return  last
    }

    public init() {
    }

}
