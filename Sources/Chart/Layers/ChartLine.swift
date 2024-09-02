//
//  ChartLine.swift
//
//  Created by Sun on 2021/11/29.
//

import UIKit

class ChartLine: ChartPointsObject {
    // MARK: Overridden Properties

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

    override var layer: CALayer {
        lineLayer
    }

    // MARK: Properties

    private let lineLayer = CAShapeLayer()

    // MARK: Computed Properties

    public var backgroundColor: UIColor? {
        didSet {
            lineLayer.backgroundColor = backgroundColor?.cgColor
        }
    }

    // MARK: Lifecycle

    override init() {
        super.init()

        lineLayer.shouldRasterize = true
        lineLayer.rasterizationScale = UIScreen.main.scale
        lineLayer.backgroundColor = UIColor.clear.cgColor

        lineLayer.fillColor = nil
    }
}
