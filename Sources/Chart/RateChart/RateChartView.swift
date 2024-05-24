import SnapKit
import UIKit

public protocol IChartViewTouchDelegate: AnyObject {
    func touchDown()
    func select(item: ChartItem, indicators: [ChartIndicator])
    func touchUp()
}

public class RateChartView: UIView {
    private let mainChart = MainChart()
    private let indicatorChart = IndicatorChart()
    private let timelineChart = TimelineChart()
    private let chartTouchArea = ChartTouchArea()

    private var viewModels = [ChartViewModel]()
    private var colorType: ChartColorType = .neutral
    private var configuration: ChartConfiguration

    public weak var delegate: IChartViewTouchDelegate?
    public private(set) var isPressed: Bool = false

    private var chartData: ChartData?
    private var indicators = [ChartIndicator]()

    public init(configuration: ChartConfiguration) {
        self.configuration = configuration

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true

        addSubview(mainChart)
        addSubview(indicatorChart)
        addSubview(timelineChart)
        addSubview(chartTouchArea)

        apply(configuration: configuration)
    }

    @discardableResult public func apply(configuration: ChartConfiguration) -> Self {
        self.configuration = configuration

        backgroundColor = configuration.backgroundColor

        mainChart.snp.remakeConstraints { maker in
            maker.leading.top.trailing.equalToSuperview()
            maker.height.equalTo(configuration.mainHeight)
        }
        mainChart.apply(configuration: configuration)

        var lastView: UIView = mainChart
        if configuration.showIndicatorArea {
            indicatorChart.snp.remakeConstraints { maker in
                maker.top.equalTo(mainChart.snp.bottom)
                maker.leading.trailing.equalToSuperview()
                maker.height.equalTo(configuration.indicatorHeight)
            }
            lastView = indicatorChart
        } else {
            indicatorChart.snp.removeConstraints()
            indicatorChart.isHidden = true
        }
        indicatorChart.apply(configuration: configuration)

        timelineChart.snp.makeConstraints { maker in
            maker.top.equalTo(lastView.snp.bottom)
            maker.leading.trailing.equalToSuperview()
            maker.height.equalTo(configuration.timelineHeight)
        }
        timelineChart.apply(configuration: configuration)

        chartTouchArea.snp.makeConstraints { maker in
            maker.leading.top.trailing.equalToSuperview()
            maker.bottom.equalTo(timelineChart.snp.top)
        }
        chartTouchArea.apply(configuration: configuration)
        if configuration.isInteractive {
            chartTouchArea.delegate = self
        }

        layoutIfNeeded()

        return self
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("not implemented")
    }

    @discardableResult public func set(chartData: ChartData, indicators: [ChartIndicator] = [], showIndicators: Bool = true, limitFormatter: ((Decimal) -> String?)? = nil, animated: Bool = true) -> [IndicatorFactory.CalculatingError] {
        // 1. calculate all indicators and add it to chartData
        let factory = IndicatorFactory()
        let calculatingErrors = factory.store(indicators: indicators, chartData: chartData)

        // 2. convert real values to visible points from 0..1 by x&y
        let ranges = RelativeConverter.ranges(chartData: chartData, indicators: indicators, showIndicators: showIndicators)
        let converted = RelativeConverter.relative(chartData: chartData, ranges: ranges)

        // 3. set points for rate and volume
        if let points = converted[ChartData.rate] {
            mainChart.set(curveRange: ranges[ChartData.rate])
            mainChart.set(points: points, animated: animated)
            chartTouchArea.set(points: points)
        }

        indicatorChart.set(volumes: converted[ChartData.volume], animated: animated)

        // 4. get diff to update all chartIndicator layers
        let updatedIds = indicators.map(\.json)

        // 4a. remove unused viewModels and apply visibility
        for model in viewModels {
            model.set(hidden: !showIndicators)
            if !updatedIds.contains(model.id) {
                // remove from chart
                if model.onChart {
                    model.remove(from: mainChart)
                } else {
                    model.remove(from: indicatorChart)
                }
                // remove indicator data from chartData
                model.remove(from: chartData)
                // remove from array
                if let index = viewModels.firstIndex(of: model) {
                    viewModels.remove(at: index)
                }
            }
        }

        // store changes after adding and deleting indicators
        self.chartData = chartData
        self.indicators = showIndicators ? indicators : []

        // 4b. update existed and add new viewModels
        for indicator in indicators {
            // 1. if already exist - will update, else create
            if let firstIndex = viewModels.firstIndex(where: { model in model.id == indicator.json }) {
                viewModels[firstIndex].set(hidden: !indicator.enabled || !showIndicators)
                viewModels[firstIndex].set(points: converted, animated: animated)
            } else {
                do {
                    let viewModel = try ChartViewModel.create(indicator: indicator, commonConfiguration: configuration)
                    if viewModel.onChart {
                        viewModel.add(to: mainChart)
                    } else {
                        viewModel.add(to: indicatorChart)
                    }
                    viewModels.append(viewModel)
                    viewModel.set(hidden: !indicator.enabled || !showIndicators)
                    viewModel.set(points: converted, animated: animated)
                } catch {
                    print("Can't create indicator: \(indicator.json) ||| \(error)")
                }
            }
        }

        // 4c. check volume visibility: show always if indicators is hidden, or show when no indicators on indicator layer enabled
        let hasVisibleOffChainIndicator = viewModels.contains { viewModel in !viewModel.onChart && !viewModel.isHidden }
        indicatorChart.setVolumes(hidden: hasVisibleOffChainIndicator && showIndicators)

        let rateRange = ranges[ChartData.rate]
        mainChart.set(highLimitText: rateRange.flatMap { limitFormatter?($0.max) }, lowLimitText: rateRange.flatMap { limitFormatter?($0.min) })

        return calculatingErrors
    }

    public func setCurve(colorType: ChartColorType) {
        self.colorType = colorType
        mainChart.setLine(colorType: colorType)
    }

    public func set(timeline: [ChartTimelineItem], start: TimeInterval, end: TimeInterval) {
        let delta = end - start
        guard !delta.isZero else {
            return
        }
        let positions = timeline.map {
            CGPoint(x: CGFloat(($0.timestamp - start) / delta), y: 0)
        }

        mainChart.setVerticalLines(points: positions)
        indicatorChart.setVerticalLines(points: positions)

        timelineChart.set(texts: timeline.map(\.text), positions: positions)
    }

    public func setVolumes(hidden: Bool) {
        indicatorChart.setVolumes(hidden: hidden)
    }

    public func setLimits(hidden: Bool) {
        mainChart.setLimits(hidden: hidden)
    }
}

extension RateChartView: ITouchAreaDelegate {
    func touchDown() {
        isPressed = true
        mainChart.setLine(colorType: .pressed)
        viewModels.forEach { $0.set(selected: true) }

        delegate?.touchDown()
    }

    func select(at index: Int) {
        guard let data = chartData,
              index < data.visibleItems.count,
              let item = chartData?.visibleItems[index]
        else {
            return
        }

        delegate?.select(item: item, indicators: indicators)
    }

    func touchUp() {
        isPressed = false
        mainChart.setLine(colorType: colorType)
        viewModels.forEach { $0.set(selected: false) }

        delegate?.touchUp()
    }
}
