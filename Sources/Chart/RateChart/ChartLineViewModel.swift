import UIKit

class ChartLineConfiguration {
    public var lineColor: UIColor = UIColor.blue
    public var lineWidth: CGFloat = 1
}

class ChartLineViewModel: ChartViewModel {
    private let maLine = ChartLine()

    private var configuration: ChartLineConfiguration

    init(id: String, onChart: Bool, configuration: ChartLineConfiguration) {
        self.configuration = configuration
        super.init(id: id, onChart: onChart)

        maLine.width = configuration.lineWidth
        maLine.strokeColor = configuration.lineColor
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
        maLine.layer.isHidden = hidden
    }

    override func set(selected: Bool) {
        // don't change colors
    }

}
