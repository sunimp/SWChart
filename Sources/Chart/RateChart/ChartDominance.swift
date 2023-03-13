import UIKit

class ChartDominance {
    private let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    private let dominance = ChartLine()

    private var configuration: ChartConfiguration?

    init(configuration: ChartConfiguration? = nil) {
        if let configuration = configuration {
            apply(configuration: configuration)
        }
    }

    @discardableResult func apply(configuration: ChartConfiguration) -> Self {
        self.configuration = configuration

        dominance.strokeColor = configuration.dominanceLineColor
        dominance.width = configuration.dominanceLineWidth
        dominance.animationStyle = .strokeEnd
        dominance.padding = configuration.curvePadding
        dominance.animationDuration = configuration.animationDuration

        return self
    }

    @discardableResult func add(to chart: Chart) -> Self {
        chart.add(dominance)

        return self
    }

    func set(values: [CGPoint]?, animated: Bool) {
        dominance.set(points: values ?? [], animated: animated)
    }

    func set(hidden: Bool) {
        dominance.layer.isHidden = hidden
    }

    func set(selected: Bool) {
        // don't change colors
    }

    private func format(percentValue: Decimal, signed: Bool = true) -> String? {
        let plusSign = (percentValue > 0 && signed) ? "+" : ""

        let formattedDiff = percentFormatter.string(from: percentValue as NSNumber)
        return formattedDiff.map { plusSign + $0 + "%" }
    }

}
