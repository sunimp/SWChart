//
//  ChartLineBottomGradient.swift
//  SWChart
//
//  Created by Sun on 2024/8/15.
//

import UIKit

class ChartLineBottomGradient: ChartPointsObject {
    // MARK: Overridden Properties

    override var layer: CALayer {
        gradientLayer
    }

    override var animationLayer: CALayer {
        maskLayer
    }

    // MARK: Properties

    private let gradientLayer = CAGradientLayer()
    private let maskLayer = CAShapeLayer()

    // MARK: Computed Properties

    public var backgroundColor: UIColor? {
        didSet {
            gradientLayer.backgroundColor = backgroundColor?.cgColor
        }
    }

    public var gradientColors: [UIColor] = [.clear] {
        didSet {
            gradientLayer.colors = gradientColors.map(\.cgColor)
        }
    }

    public var gradientLocations: [NSNumber]? = nil {
        didSet {
            gradientLayer.locations = gradientLocations
        }
    }

    // MARK: Lifecycle

    override init() {
        super.init()

        gradientLayer.shouldRasterize = true
        gradientLayer.rasterizationScale = UIScreen.main.scale
        gradientLayer.anchorPoint = .zero

        maskLayer.shouldRasterize = true
        maskLayer.rasterizationScale = UIScreen.main.scale

        gradientLayer.backgroundColor = UIColor.clear.cgColor
        gradientLayer.mask = maskLayer
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
    }

    // MARK: Overridden Functions

    override func absolute(points: [CGPoint]) -> [CGPoint] {
        let absolutePoints = points
            .map { ShapeHelper.convertRelative(point: $0, size: gradientLayer.bounds.size, padding: padding) }
        return ShapeHelper.closePoints(points: absolutePoints, size: gradientLayer.bounds.size)
    }

    override func appearingAnimation(
        new: [CGPoint],
        duration: CFTimeInterval,
        timingFunction: CAMediaTimingFunction?
    )
        -> CAAnimation? {
        switch animationStyle {
        case .verticalGrowing:
            return super.appearingAnimation(new: new, duration: duration, timingFunction: timingFunction)
        case .strokeEnd:
            let startBounds = CGRect(x: 0, y: 0, width: 0, height: gradientLayer.bounds.height)
            let boundsAnimation = ShapeHelper.animation(
                keyPath: "bounds",
                from: startBounds,
                to: gradientLayer.bounds,
                duration: duration,
                timingFunction: timingFunction
            )
            gradientLayer.add(boundsAnimation, forKey: strokeAnimationKey)
            return CABasicAnimation(keyPath: animationKey)
        }
    }
}
