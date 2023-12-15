import UIKit

class ChartLineConfiguration {
    public var lineColor: UIColor = .blue
    public var lineWidth: CGFloat = 1

    public var animationDuration: TimeInterval = 0.35
    public var padding: UIEdgeInsets = .init(top: 18, left: 0, bottom: 18, right: 0)
    public var bottomInset: CGFloat = 0

    static func configured(_ configuration: ChartConfiguration, onChart: Bool) -> ChartLineConfiguration {
        let config = ChartLineConfiguration()

        config.animationDuration = configuration.animationDuration
        config.padding = onChart ? configuration.curvePadding : configuration.indicatorAreaPadding
        config.bottomInset = onChart ? configuration.curveBottomInset : 0
        return config
    }
}

class ChartLineViewModel: ChartViewModel {
    private let maLine = ChartLine()

    private var configuration: ChartLineConfiguration

    init(id: String, onChart: Bool, configuration: ChartLineConfiguration) {
        self.configuration = configuration
        super.init(id: id, onChart: onChart)

        maLine.width = configuration.lineWidth
        maLine.strokeColor = configuration.lineColor
        maLine.padding = configuration.padding
        maLine.bottomInset = configuration.bottomInset
    }

    @discardableResult override func add(to chart: Chart) -> Self {
        chart.add(maLine)
        return self
    }

    @discardableResult override func remove(from chart: Chart) -> Self {
        chart.remove(maLine)
        return self
    }

    override func set(points: [String: [CGPoint]], animated: Bool) {
        maLine.set(points: points[id], animated: animated)
    }

    override func set(hidden: Bool) {
        super.set(hidden: hidden)
        maLine.layer.isHidden = hidden
    }

    override func set(selected _: Bool) {
        // don't change colors
    }
}
