import UIKit

public class ChartMacdConfiguration {
    public var animationDuration: TimeInterval = 0.35

    public var histogramPadding: UIEdgeInsets = .init(top: 8, left: 0, bottom: 8, right: 0)
    public var linesPadding: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)

    public var signalColor: UIColor = .blue
    public var signalLineWidth: CGFloat = 1
    public var macdColor: UIColor = .orange
    public var histogramWidth: CGFloat = 8
    public var lineWidth: CGFloat = 1
    public var positiveColor: UIColor = .green.withAlphaComponent(0.5)
    public var negativeColor: UIColor = .red.withAlphaComponent(0.5)

    static func configured(_ configuration: ChartConfiguration, onChart: Bool) -> ChartMacdConfiguration {
        let config = ChartMacdConfiguration()
        config.histogramPadding = onChart ? configuration.curvePadding : configuration.indicatorAreaPadding
        config.linesPadding = onChart ? configuration.curvePadding : configuration.indicatorAreaPadding
        config.animationDuration = configuration.animationDuration

        return config
    }

    @discardableResult func configured(_ configuration: MacdIndicator.Configuration) -> Self {
        signalColor = configuration.fastColor.value
        macdColor = configuration.longColor.value
        positiveColor = configuration.positiveColor.value
        negativeColor = configuration.negativeColor.value
        histogramWidth = configuration.width
        lineWidth = configuration.signalWidth
        return self
    }
}

class ChartMacdViewModel: ChartViewModel {
    private let histogram = ChartHistogram()
    private let signal = ChartLine()
    private let macd = ChartLine()

    private var configuration: ChartMacdConfiguration

    init(id: String, onChart: Bool, configuration: ChartMacdConfiguration) {
        self.configuration = configuration
        super.init(id: id, onChart: onChart)

        apply(configuration: configuration)
    }

    @discardableResult func apply(configuration: ChartMacdConfiguration) -> Self {
        self.configuration = configuration

        histogram.positiveBarFillColor = configuration.positiveColor
        histogram.negativeBarFillColor = configuration.negativeColor
        histogram.width = configuration.histogramWidth
        histogram.padding = configuration.histogramPadding
        histogram.animationDuration = configuration.animationDuration

        signal.strokeColor = configuration.signalColor
        signal.width = configuration.signalLineWidth
        signal.padding = configuration.linesPadding
        signal.animationDuration = configuration.animationDuration

        macd.strokeColor = configuration.macdColor
        macd.width = configuration.lineWidth
        macd.padding = configuration.linesPadding
        macd.animationDuration = configuration.animationDuration

        return self
    }

    @discardableResult override func add(to chart: Chart) -> Self {
        chart.add(histogram)
        chart.add(signal)
        chart.add(macd)

        return self
    }

    override func remove(from chart: Chart) -> Self {
        chart.remove(histogram)
        chart.remove(signal)
        chart.remove(macd)

        super.remove(from: chart)
        return self
    }

    override func remove(from chartData: ChartData) -> Self {
        chartData.removeIndicator(id: MacdIndicator.MacdType.signal.name(id: id))
        chartData.removeIndicator(id: MacdIndicator.MacdType.macd.name(id: id))
        chartData.removeIndicator(id: MacdIndicator.MacdType.histogram.name(id: id))
        return self
    }

    override func set(points: [String: [CGPoint]], animated: Bool) {
        signal.set(points: points[MacdIndicator.MacdType.signal.name(id: id)] ?? [], animated: animated)
        macd.set(points: points[MacdIndicator.MacdType.macd.name(id: id)] ?? [], animated: animated)
        histogram.set(points: points[MacdIndicator.MacdType.histogram.name(id: id)] ?? [], animated: animated)
    }

    func set(macd: [CGPoint]?, macdHistogram: [CGPoint]?, macdSignal: [CGPoint]?, animated: Bool) {
        self.macd.set(points: macd ?? [], animated: animated)
        histogram.set(points: macdHistogram ?? [], animated: animated)
        signal.set(points: macdSignal ?? [], animated: animated)
    }

    override func set(hidden: Bool) {
        super.set(hidden: hidden)
        macd.layer.isHidden = hidden
        histogram.layer.isHidden = hidden
        signal.layer.isHidden = hidden
    }

    override func set(selected _: Bool) {
        // dont change colors
    }
}
