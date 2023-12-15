import UIKit

class IndicatorChart: Chart {
    private let volumeBars = ChartBars()
    private let verticalLines = ChartGridLines()
    private let horizontalLines = ChartGridLines()

    private var showVolume: Bool = true

    init(configuration: ChartConfiguration? = nil) {
        super.init(frame: .zero)

        add(verticalLines)
        add(volumeBars)
        add(horizontalLines)

        if let configuration {
            apply(configuration: configuration)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @discardableResult func apply(configuration: ChartConfiguration) -> Self {
        volumeBars.barFillColor = configuration.volumeBarsFillColor
        volumeBars.width = configuration.volumeBarsWidth
        volumeBars.strokeColor = configuration.volumeBarsColor
        volumeBars.padding = configuration.indicatorAreaPadding
        volumeBars.animationDuration = configuration.animationDuration

        if configuration.showVerticalLines {
            verticalLines.gridType = .vertical
            verticalLines.lineDirection = .top
            verticalLines.width = configuration.verticalLinesWidth
            verticalLines.invisibleIndent = configuration.verticalInvisibleIndent

            verticalLines.strokeColor = configuration.verticalLinesColor
        }

        horizontalLines.gridType = .horizontal
        horizontalLines.width = configuration.borderWidth
        horizontalLines.strokeColor = configuration.borderColor
        horizontalLines.set(points: [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0)])
        horizontalLines.layer.isHidden = !configuration.showBorders

        return self
    }

    func set(volumes: [CGPoint]?, animated: Bool = false) {
        volumeBars.set(points: volumes ?? [], animated: animated)
    }

    func setVolumeColor(color: UIColor) {
        volumeBars.barFillColor = color
    }

    func setVolumes(hidden: Bool) {
        volumeBars.layer.isHidden = hidden
    }

    func setVerticalLines(points: [CGPoint], animated: Bool = false) {
        verticalLines.set(points: points, animated: animated)
    }

    func setVerticalLines(hidden: Bool) {
        verticalLines.layer.isHidden = hidden
    }

    func setHorizontalLines(hidden: Bool) {
        horizontalLines.layer.isHidden = hidden
    }
}
