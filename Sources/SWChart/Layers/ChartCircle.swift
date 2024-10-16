//
//  ChartCircle.swift
//  SWChart
//
//  Created by Sun on 2024/8/15.
//

import UIKit

class ChartCircle: ChartPointsObject {
    // MARK: Overridden Properties

    override public var strokeColor: UIColor {
        didSet {
            circleLayer.strokeColor = strokeColor.cgColor
        }
    }

    override var layer: CALayer {
        circleLayer
    }

    override var fillColor: UIColor {
        didSet {
            circleLayer.fillColor = fillColor.cgColor
        }
    }

    override var width: CGFloat {
        didSet {
            circleLayer.lineWidth = width
        }
    }

    // MARK: Properties

    public var radius: CGFloat = 3

    private let circleLayer = CAShapeLayer()

    // MARK: Computed Properties

    public var backgroundColor: UIColor? {
        didSet {
            circleLayer.fillColor = backgroundColor?.cgColor
        }
    }

    // MARK: Lifecycle

    override init() {
        super.init()

        circleLayer.shouldRasterize = true
        circleLayer.rasterizationScale = UIScreen.main.scale

        circleLayer.backgroundColor = UIColor.clear.cgColor

        circleLayer.lineWidth = 1 / UIScreen.main.scale
    }

    // MARK: Overridden Functions

    override func path(points: [CGPoint]) -> CGPath {
        let path = UIBezierPath()

        guard !points.isEmpty else {
            return path.cgPath
        }

        for point in points {
            path.addArc(withCenter: point, radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        }

        return path.cgPath
    }

    override func updateFrame(in bounds: CGRect, duration: CFTimeInterval?, timingFunction: CAMediaTimingFunction?) {
        super.updateFrame(in: bounds, duration: duration, timingFunction: timingFunction)
    }
}
