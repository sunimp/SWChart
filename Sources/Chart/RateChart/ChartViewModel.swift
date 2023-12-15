import Foundation

class ChartViewModel: Equatable {
    let id: String
    let onChart: Bool
    private(set) var isHidden: Bool = false

    init(id: String, onChart: Bool) {
        self.id = id
        self.onChart = onChart
    }

    @discardableResult func add(to _: Chart) -> Self { self }
    @discardableResult func remove(from _: Chart) -> Self { self }
    @discardableResult func remove(from chartData: ChartData) -> Self {
        chartData.removeIndicator(id: id)
        return self
    }

    func set(points _: [String: [CGPoint]], animated _: Bool) {}
    func set(hidden: Bool) {
        isHidden = hidden
    }

    func set(selected _: Bool) {}

    static func == (lhs: ChartViewModel, rhs: ChartViewModel) -> Bool {
        lhs.id == rhs.id
    }
}

extension ChartViewModel {
    static func create(indicator: ChartIndicator, commonConfiguration: ChartConfiguration) throws -> ChartViewModel {
        let id = indicator.json

        switch indicator {
        case let indicator as PrecalculatedIndicator:
            let configuration = ChartLineConfiguration.configured(commonConfiguration, onChart: indicator.onChart)
            configuration.lineWidth = indicator.configuration.width
            configuration.lineColor = indicator.configuration.color.value

            return ChartLineViewModel(id: id, onChart: indicator.onChart, configuration: configuration)
        case let indicator as MaIndicator:
            let configuration = ChartLineConfiguration.configured(commonConfiguration, onChart: indicator.onChart)
            configuration.lineWidth = indicator.configuration.width
            configuration.lineColor = indicator.configuration.color.value

            return ChartLineViewModel(id: id, onChart: indicator.onChart, configuration: configuration)
        case let indicator as RsiIndicator:
            let configuration = ChartRsiConfiguration.configured(commonConfiguration, onChart: indicator.onChart)
            configuration.lineWidth = indicator.configuration.width
            configuration.lineColor = indicator.configuration.color.value

            return ChartRsiViewModel(id: id, onChart: indicator.onChart, configuration: configuration)
        case let indicator as MacdIndicator:
            let configuration = ChartMacdConfiguration.configured(commonConfiguration, onChart: indicator.onChart).configured(indicator.configuration)
            return ChartMacdViewModel(id: id, onChart: indicator.onChart, configuration: configuration)
        default: throw IndicatorCalculator.IndicatorError.invalidIndicator
        }
    }
}
