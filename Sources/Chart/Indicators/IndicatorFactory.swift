import Foundation

public class IndicatorFactory {
    public func store(indicators: [ChartIndicator], chartData: ChartData) -> [CalculatingError] {
        // 1. get all rates to calculate indicators
        let rates = chartData.values(name: ChartData.rate)

        var errors = [CalculatingError]()

        for indicator in indicators {
            do {
                let indicatorName = indicator.json
                switch indicator {
                case let indicator as PrecalculatedIndicator:
                    // just add values by id
                    chartData.add(name: indicatorName, values: indicator.values)
                case let indicator as MaIndicator:
                    // calculate data
                    let values: [Decimal]
                    switch indicator.type {
                    case .ema: values = try IndicatorCalculator.ema(period: indicator.period, values: rates)
                    case .sma: values = try IndicatorCalculator.ma(period: indicator.period, values: rates)
                    case .wma: values = try IndicatorCalculator.wma(period: indicator.period, values: rates)
                    }
                    chartData.add(name: indicatorName, values: values)
                case let indicator as RsiIndicator:
                    // calculate data
                    let values = try IndicatorCalculator.rsi(period: indicator.period, values: rates)
                    chartData.add(name: indicatorName, values: values)
                case let indicator as MacdIndicator:
                    // calculate data
                    let values = try IndicatorCalculator.macd(fast: indicator.fast, long: indicator.slow, signal: indicator.signal, values: rates)
                    // TODO: remove or replace MacdIndicator.MacdType.macd.name(id: indicatorName)
                    chartData.add(name: MacdIndicator.MacdType.macd.name(id: indicatorName), values: values.macd)
                    chartData.add(name: MacdIndicator.MacdType.signal.name(id: indicatorName), values: values.signal)
                    chartData.add(name: MacdIndicator.MacdType.histogram.name(id: indicatorName), values: values.histogram)
                default: throw IndicatorCalculator.IndicatorError.invalidIndicator
                }
            } catch {
                errors.append(CalculatingError(id: indicator.json, error: error))
            }
        }
        return errors
    }

    public init() {}
}

public extension IndicatorFactory {
    struct CalculatingError {
        public let id: String
        public let error: Error

        public init(id: String, error: Error) {
            self.id = id
            self.error = error
        }
    }
}
