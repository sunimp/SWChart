//
//  ChartViewModel.swift
//
//  Created by Sun on 2023/6/20.
//

import Foundation

// MARK: - ChartViewModel

class ChartViewModel: Equatable {
    // MARK: Properties

    let id: String
    let onChart: Bool
    private(set) var isHidden = false

    // MARK: Lifecycle

    init(id: String, onChart: Bool) {
        self.id = id
        self.onChart = onChart
    }

    // MARK: Static Functions

    static func == (lhs: ChartViewModel, rhs: ChartViewModel) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: Functions

    @discardableResult
    func add(to _: Chart) -> Self { self }
    @discardableResult
    func remove(from _: Chart) -> Self { self }
    @discardableResult
    func remove(from chartData: ChartData) -> Self {
        chartData.removeIndicator(id: id)
        return self
    }

    func set(points _: [String: [CGPoint]], animated _: Bool) { }
    func set(hidden: Bool) {
        isHidden = hidden
    }

    func set(selected _: Bool) { }
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
            let configuration = ChartMacdConfiguration.configured(commonConfiguration, onChart: indicator.onChart)
                .configured(indicator.configuration)
            return ChartMacdViewModel(id: id, onChart: indicator.onChart, configuration: configuration)

        default: throw IndicatorCalculator.IndicatorError.invalidIndicator
        }
    }
}
