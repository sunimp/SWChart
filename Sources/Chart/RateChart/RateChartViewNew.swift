//import UIKit
//import SnapKit
//
//public protocol IChartViewTouchNewDelegate: AnyObject {
//    func touchDown()
//    func select(item: ChartItem)
//    func touchUp()
//}
//
//public class RateChartViewNew: UIView {
//    private let mainChart = MainChart()
//    private let indicatorChart = IndicatorChart()
//    private let timelineChart = TimelineChart()
//    private let chartTouchArea = ChartTouchArea()
//
//    private let indicators = [String: ChartViewModel]()
//
//    private var colorType: ChartColorType = .neutral
//    private var configuration: ChartConfiguration?
//
//    public weak var delegate: IChartViewTouchDelegate?
//
//    private var chartData: ChartData?
//
//    public init(configuration: ChartConfiguration? = nil) {
//        super.init(frame: .zero)
//
//        translatesAutoresizingMaskIntoConstraints = false
//        clipsToBounds = true
//
//        addSubview(mainChart)
//        addSubview(indicatorChart)
//        addSubview(timelineChart)
//        addSubview(chartTouchArea)
//
//        if let configuration = configuration {
//            apply(configuration: configuration)
//        }
//    }
//
//    @discardableResult public func apply(configuration: ChartConfiguration) -> Self {
//        self.configuration = configuration
//
//        backgroundColor = configuration.backgroundColor
//
//        mainChart.snp.remakeConstraints { maker in
//            maker.leading.top.trailing.equalToSuperview()
//            maker.height.equalTo(configuration.mainHeight)
//        }
//        mainChart.apply(configuration: configuration)
//
//        var lastView: UIView = mainChart
//        if configuration.showIndicators {
//            indicatorChart.snp.remakeConstraints { maker in
//                maker.top.equalTo(mainChart.snp.bottom)
//                maker.leading.trailing.equalToSuperview()
//                maker.height.equalTo(configuration.indicatorHeight)
//            }
//            lastView = indicatorChart
//        } else {
//            indicatorChart.snp.removeConstraints()
//            indicatorChart.isHidden = true
//        }
//        indicatorChart.apply(configuration: configuration)
//
//        timelineChart.snp.makeConstraints { maker in
//            maker.top.equalTo(lastView.snp.bottom)
//            maker.leading.trailing.equalToSuperview()
//            maker.height.equalTo(configuration.timelineHeight)
//        }
//        timelineChart.apply(configuration: configuration)
//
//        chartTouchArea.snp.makeConstraints { maker in
//            maker.leading.top.trailing.equalToSuperview()
//            maker.bottom.equalTo(timelineChart.snp.top)
//        }
//        chartTouchArea.apply(configuration: configuration)
//        if configuration.isInteractive {
//            chartTouchArea.delegate = self
//        }
//
//        layoutIfNeeded()
//
//        return self
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("not implemented")
//    }
//
//    public func set(chartData: ChartData, animated: Bool = true) {
//        self.chartData = chartData
//
//        let converted = RelativeConverter.convert(chartData: chartData)
//
//        if let points = converted[ChartData.rate] {
//            mainChart.set(points: points, animated: animated)
//            chartTouchArea.set(points: points)
//        }
//        indicatorChart.set(volumes: converted[ChartData.volume] ?? [], animated: animated)
//    }
//
//    public func setCurve(colorType: ChartColorType) {
//        guard configuration != nil else {
//            return
//        }
//        self.colorType = colorType
//        mainChart.setLine(colorType: colorType)
//    }
//
//    public func set(timeline: [ChartTimelineItem], start: TimeInterval, end: TimeInterval) {
//        let delta = end - start
//        guard !delta.isZero else {
//            return
//        }
//        let positions = timeline.map {
//            CGPoint(x: CGFloat(($0.timestamp - start) / delta), y: 0)
//        }
//
//        mainChart.setVerticalLines(points: positions)
//        indicatorChart.setVerticalLines(points: positions)
//
//        timelineChart.set(texts: timeline.map { $0.text }, positions: positions)
//    }
//
//    public func setVolumes(hidden: Bool) {
//        indicatorChart.setVolumes(hidden: hidden)
//    }
//
//    public func setLimits(hidden: Bool) {
//        mainChart.setLimits(hidden: hidden)
//    }
//
//    public func set(highLimitText: String?, lowLimitText: String?) {
//        mainChart.set(highLimitText: highLimitText, lowLimitText: lowLimitText)
//    }
//
//}
//
//extension RateChartViewNew: ITouchAreaDelegate {
//
//    func touchDown() {
//        guard configuration != nil else {
//            return
//        }
//
//        mainChart.setLine(colorType: .pressed)
//
//        indicators.forEach { key, indicator in
//            indicator.set(selected: true)
//        }
//
//        delegate?.touchDown()
//    }
//
//    func select(at index: Int) {
//        guard let data = chartData,
//              index < data.items.count,
//              let item = chartData?.items[index] else {
//
//            return
//        }
//
//        delegate?.select(item: item)
//    }
//
//    func touchUp() {
//        mainChart.setLine(colorType: colorType)
//
//        indicators.forEach { key, indicator in
//            indicator.set(selected: false)
//        }
//
//        delegate?.touchUp()
//    }
//
//}
