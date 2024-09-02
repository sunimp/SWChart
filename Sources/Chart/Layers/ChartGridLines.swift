//
//  ChartGridLines.swift
//
//  Created by Sun on 2021/11/29.
//

import UIKit

// MARK: - ChartGridType

enum ChartGridType {
    case horizontal
    case vertical
}

// MARK: - ChartGridLines

class ChartGridLines: ChartPointsObject {
    // MARK: Overridden Properties

    override public var strokeColor: UIColor {
        didSet {
            linesLayer.strokeColor = strokeColor.cgColor
        }
    }

    override public var width: CGFloat {
        didSet {
            linesLayer.lineWidth = width
        }
    }

    override public var bottomInset: CGFloat {
        didSet {
            linesLayer.displayIfNeeded()
        }
    }

    override var layer: CALayer {
        linesLayer
    }

    override var fillColor: UIColor {
        didSet {
            linesLayer.fillColor = fillColor.cgColor
        }
    }

    // MARK: Properties

    var lineDirection: ChartPathDirection = .bottom
    var gridType: ChartGridType = .horizontal

    var invisibleIndent: CGFloat?

    private let linesLayer = CAShapeLayer()

    // MARK: Computed Properties

    public var backgroundColor: UIColor? {
        didSet {
            linesLayer.backgroundColor = backgroundColor?.cgColor
        }
    }

    public var lineDashPattern: [NSNumber]? = nil {
        didSet {
            linesLayer.lineDashPattern = lineDashPattern
        }
    }

    public var retinaCorrected = true {
        didSet {
            linesLayer.setNeedsDisplay()
        }
    }

    // MARK: Lifecycle

    override init() {
        super.init()

        linesLayer.shouldRasterize = true
        linesLayer.rasterizationScale = UIScreen.main.scale

        linesLayer.backgroundColor = UIColor.clear.cgColor
        linesLayer.fillColor = UIColor.clear.cgColor

        linesLayer.lineWidth = width
    }

    // MARK: Overridden Functions

    override func path(points: [CGPoint]) -> CGPath {
        let path = UIBezierPath()

        guard !points.isEmpty else {
            return path.cgPath
        }

        let offset = retinaCorrected ? LayerFrameHelper.offset(lineWidth: width) : 0

        for point in points {
            if
                let invisibleIndent, // if point closer than ignoring size, dont show line
                (point.x <= layer.bounds.origin.x + invisibleIndent) ||
                (point.x >= layer.bounds.width - invisibleIndent) {
                continue
            }
            let correctedPoint = retinaCorrected ? CGPoint(x: ceil(point.x) + offset, y: ceil(point.y) + offset) : point

            path.move(to: correctedPoint)
            let endPoint: CGPoint
            switch gridType {
            case .horizontal:
                let toX = lineDirection == .bottom ? (linesLayer.bounds.width) : 0
                endPoint = CGPoint(x: toX + offset, y: correctedPoint.y)

            case .vertical:
                let toY = lineDirection == .bottom ? (linesLayer.bounds.height - bottomInset) : bottomInset
                endPoint = CGPoint(x: correctedPoint.x, y: toY + offset)
            }
            path.addLine(to: endPoint)
        }

        return path.cgPath
    }

    override func updateFrame(in bounds: CGRect, duration: CFTimeInterval?, timingFunction: CAMediaTimingFunction?) {
        super.updateFrame(in: bounds, duration: duration, timingFunction: timingFunction)
    }
}
