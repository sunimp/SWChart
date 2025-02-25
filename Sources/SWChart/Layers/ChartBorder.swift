//
//  ChartBorder.swift
//  SWChart
//
//  Created by Sun on 2024/8/15.
//

import UIKit

class ChartBorder: IChartObject {
    // MARK: Properties

    public var insets: UIEdgeInsets = .zero
    public var size: CGSize? = nil

    public var padding: UIEdgeInsets = .zero

    private let borderLayer = CAShapeLayer()

    // MARK: Computed Properties

    public var backgroundColor: UIColor? {
        didSet {
            borderLayer.backgroundColor = backgroundColor?.cgColor
        }
    }

    public var strokeColor: UIColor = .clear {
        didSet {
            borderLayer.strokeColor = strokeColor.cgColor
        }
    }

    public var lineWidth: CGFloat = 1 {
        didSet {
            borderLayer.lineWidth = lineWidth
        }
    }

    public var lineDashPattern: [NSNumber]? = nil {
        didSet {
            borderLayer.lineDashPattern = lineDashPattern
        }
    }

    var layer: CALayer {
        borderLayer
    }

    // MARK: Lifecycle

    init() {
        borderLayer.shouldRasterize = true
        borderLayer.rasterizationScale = UIScreen.main.scale

        borderLayer.backgroundColor = UIColor.clear.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor

        borderLayer.lineWidth = lineWidth
    }

    // MARK: Functions

    func path() -> CGPath {
        let offset: CGFloat = LayerFrameHelper.offset(lineWidth: lineWidth)

//        let size = CGSize(width: borderLayer.bounds.width - 2 * offset, height: borderLayer.bounds.height)// - 1 /
//        UIScreen.main.scale)
//        return UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: offset, y: offset), size: size), cornerRadius:
//        0).cgPath

//      only bottom chart border
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: borderLayer.bounds.height - offset))
        path.addLine(to: CGPoint(x: borderLayer.bounds.width - 2 * offset, y: borderLayer.bounds.height - offset))
        return path.cgPath
    }

    func updateFrame(in bounds: CGRect, duration _: CFTimeInterval?, timingFunction _: CAMediaTimingFunction?) {
        borderLayer.frame = LayerFrameHelper.frame(insets: insets, size: size, in: bounds)

        borderLayer.path = path()
    }
}
