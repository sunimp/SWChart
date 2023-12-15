import UIKit

public class ChartRsiConfiguration {
    public var animationDuration: TimeInterval = 0.35

    public var lineColor: UIColor = .blue
    public var lineWidth: CGFloat = 1

    public var padding: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
    public var topLimitValue: CGFloat = 0.7
    public var bottomLimitValue: CGFloat = 0.3

    public var highTextInsets: UIEdgeInsets = .init(top: 6, left: 16, bottom: -1, right: -1)
    public var lowTextInsets: UIEdgeInsets = .init(top: -1, left: 16, bottom: -2, right: -1)

    public var textSize: CGSize = .init(width: 15, height: 14)

    public var limitLinesWidth: CGFloat = ChartConfiguration.onePixel
    public var limitLinesDashPattern: [NSNumber]? = [2, 2]
    public var limitLinesColor: UIColor = .white.withAlphaComponent(0.5)

    public var limitTextColor: UIColor = .white.withAlphaComponent(0.5)
    public var limitTextFont: UIFont = .systemFont(ofSize: 10)

    static func configured(_ configuration: ChartConfiguration, onChart: Bool) -> ChartRsiConfiguration {
        let config = ChartRsiConfiguration()
        config.animationDuration = configuration.animationDuration

        config.padding = onChart ? configuration.curvePadding : configuration.indicatorAreaPadding
        config.topLimitValue = configuration.rsiTopLimitValue
        config.bottomLimitValue = configuration.rsiBottomLimitValue

        config.highTextInsets = configuration.rsiHighTextInsets
        config.lowTextInsets = configuration.rsiLowTextInsets

        config.textSize = configuration.rsiTextSize

        config.limitLinesWidth = configuration.limitLinesWidth
        config.limitLinesDashPattern = configuration.limitLinesDashPattern
        config.limitLinesColor = configuration.limitLinesColor

        config.limitTextColor = configuration.limitTextColor
        config.limitTextFont = configuration.limitTextFont

        return config
    }
}

class ChartRsiViewModel: ChartViewModel {
    private let rsi = ChartLine()

    private let rsiLimitLines = ChartGridLines()
    private let rsiTopValue = ChartText()
    private let rsiBottomValue = ChartText()

    private var configuration: ChartRsiConfiguration

    init(id: String, onChart: Bool, configuration: ChartRsiConfiguration) {
        self.configuration = configuration
        super.init(id: id, onChart: onChart)

        apply(configuration: configuration)
    }

    @discardableResult func apply(configuration: ChartRsiConfiguration) -> Self {
        self.configuration = configuration

        rsi.strokeColor = configuration.lineColor
        rsi.width = configuration.lineWidth
        rsi.animationStyle = .strokeEnd
        rsi.padding = configuration.padding
        rsi.animationDuration = configuration.animationDuration

        rsiLimitLines.strokeColor = configuration.limitLinesColor
        rsiLimitLines.width = configuration.limitLinesWidth
        rsiLimitLines.lineDashPattern = configuration.limitLinesDashPattern
        rsiLimitLines.padding = configuration.padding
        rsiLimitLines.set(points: [CGPoint(x: 0, y: configuration.bottomLimitValue), CGPoint(x: 0, y: configuration.topLimitValue)])

        rsiTopValue.textColor = configuration.limitTextColor
        rsiTopValue.font = configuration.limitTextFont
        rsiTopValue.insets = configuration.highTextInsets
        rsiTopValue.size = configuration.textSize

        rsiBottomValue.textColor = configuration.limitTextColor
        rsiBottomValue.font = configuration.limitTextFont
        rsiBottomValue.insets = configuration.lowTextInsets
        rsiBottomValue.size = configuration.textSize

        rsiTopValue.set(text: "\(configuration.topLimitValue * 100)")
        rsiBottomValue.set(text: "\(configuration.bottomLimitValue * 100)")

        return self
    }

    @discardableResult override func add(to chart: Chart) -> Self {
        chart.add(rsi)
        chart.add(rsiLimitLines)
        chart.add(rsiTopValue)
        chart.add(rsiBottomValue)

        return self
    }

    override func remove(from chart: Chart) -> Self {
        chart.remove(rsi)
        chart.remove(rsiLimitLines)
        chart.remove(rsiTopValue)
        chart.remove(rsiBottomValue)
        return self
    }

    override func set(points: [String: [CGPoint]], animated: Bool) {
        rsi.set(points: points[id] ?? [], animated: animated)
    }

    override func set(hidden: Bool) {
        super.set(hidden: hidden)
        rsi.layer.isHidden = hidden
        rsiLimitLines.layer.isHidden = hidden
        rsiTopValue.layer.isHidden = hidden
        rsiBottomValue.layer.isHidden = hidden
    }

    override func set(selected _: Bool) {
        // dont change colors
    }
}
