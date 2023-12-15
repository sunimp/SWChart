import UIKit

class ChartLine: ChartPointsObject {
    private let lineLayer = CAShapeLayer()

    override var layer: CALayer {
        lineLayer
    }

    public var backgroundColor: UIColor? {
        didSet {
            lineLayer.backgroundColor = backgroundColor?.cgColor
        }
    }

    override public var fillColor: UIColor {
        didSet {
            lineLayer.fillColor = fillColor.cgColor
        }
    }

    override public var strokeColor: UIColor {
        didSet {
            lineLayer.strokeColor = strokeColor.cgColor
        }
    }

    override public var width: CGFloat {
        didSet {
            lineLayer.lineWidth = width
        }
    }

    override init() {
        super.init()

        lineLayer.shouldRasterize = true
        lineLayer.rasterizationScale = UIScreen.main.scale
        lineLayer.backgroundColor = UIColor.clear.cgColor

        lineLayer.fillColor = nil
    }
}
