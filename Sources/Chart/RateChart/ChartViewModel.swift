import Foundation

class ChartViewModel: Equatable {
    let id: String
    let onChart: Bool

    init(id: String, onChart: Bool) {
        self.id = id
        self.onChart = onChart
    }

    @discardableResult func add(to chart: Chart) -> Self { self }
    @discardableResult func remove(from chart: Chart) -> Self { self }
    @discardableResult func remove(from chartData: ChartData) -> Self {
        chartData.removeIndicator(id: id)
        return self
    }

    func set(points: [String: [CGPoint]], animated: Bool) {}
    func set(hidden: Bool) {}
    func set(selected: Bool) {}

    static func ==(lhs: ChartViewModel, rhs: ChartViewModel) -> Bool {
        lhs.id == rhs.id
    }
}

extension ChartViewModel {

    static func create(indicator: ChartIndicator, commonConfiguration: ChartConfiguration) throws -> ChartViewModel {
        let id = indicator.json

        switch indicator {
        case let indicator as PrecalculatedIndicator:
            let configuration = ChartLineConfiguration()
            configuration.lineWidth = indicator.width
            configuration.lineColor = indicator.color.value

            return ChartLineViewModel(id: id, onChart: indicator.onChart, configuration: configuration)
        case let indicator as MaIndicator:
            let configuration = ChartLineConfiguration()
            configuration.lineWidth = indicator.width
            configuration.lineColor = indicator.color.value

            return ChartLineViewModel(id: id, onChart: indicator.onChart, configuration: configuration)
        case let indicator as RsiIndicator:
            let configuration = ChartRsiConfiguration.configured(commonConfiguration)
            configuration.lineWidth = indicator.width
            configuration.lineColor = indicator.color.value

            return ChartRsiViewModel(id: id, onChart: indicator.onChart, configuration: configuration)
        case let indicator as MacdIndicator:
            let configuration = ChartMacdConfiguration.configured(commonConfiguration).configured(indicator.configuration)
            return ChartMacdViewModel(id: id, onChart: indicator.onChart, configuration: configuration)
        default: throw CancellationError()
        }

    }
}