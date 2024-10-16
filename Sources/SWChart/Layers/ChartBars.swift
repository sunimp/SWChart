//
//  ChartBars.swift
//  SWChart
//
//  Created by Sun on 2024/8/15.
//

import UIKit

// MARK: - ChartBarPosition

enum ChartBarPosition {
    case start
    case center
    case end
}

// MARK: - ChartBars

class ChartBars: ChartPointsObject {
    // MARK: Overridden Properties

    override public var strokeColor: UIColor {
        didSet {
            barsLayer.strokeColor = strokeColor.cgColor
        }
    }

    override public var width: CGFloat {
        didSet {
            barsLayer.displayIfNeeded()
        }
    }

    override public var bottomInset: CGFloat {
        didSet {
            barsLayer.displayIfNeeded()
        }
    }

    override var layer: CALayer {
        barsLayer
    }

    override var fillColor: UIColor {
        didSet {
            barsLayer.fillColor = fillColor.cgColor
            barsLayer.displayIfNeeded()
        }
    }

    // MARK: Properties

    var barPosition: ChartBarPosition = .center
    var morphingAnimationDisabled = false

    private let onePixel: CGFloat = 1 / UIScreen.main.scale

    private let barsLayer = CAShapeLayer()
    private let maskLayer = CALayer()

    // MARK: Computed Properties

    public var backgroundColor: UIColor? {
        didSet {
            barsLayer.backgroundColor = backgroundColor?.cgColor
        }
    }

    public var barFillColor: UIColor? = nil {
        didSet {
            barsLayer.fillColor = barFillColor?.cgColor
        }
    }

    public var lineCapStyle: CGLineCap = .round {
        didSet {
            barsLayer.displayIfNeeded()
        }
    }

    // MARK: Lifecycle

    override init() {
        super.init()

        barsLayer.shouldRasterize = true
        barsLayer.rasterizationScale = UIScreen.main.scale
        barsLayer.mask = maskLayer
        barsLayer.fillColor = nil

        maskLayer.anchorPoint = .zero
        maskLayer.backgroundColor = UIColor.black.cgColor
    }

    // MARK: Overridden Functions

    override public func set(points: [CGPoint]?, animated: Bool = false) {
        super.set(points: points, animated: animated)
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
            maskLayer.bounds = barsLayer.bounds

            let startBounds = CGRect(x: 0, y: 0, width: 0, height: barsLayer.bounds.height - bottomInset)
            let boundsAnimation = ShapeHelper.animation(
                keyPath: "bounds",
                from: startBounds,
                to: barsLayer.bounds,
                duration: duration,
                timingFunction: timingFunction
            )
            maskLayer.add(boundsAnimation, forKey: strokeAnimationKey)
            return CABasicAnimation(keyPath: animationKey)
        }
    }

    override func path(points: [CGPoint]) -> CGPath {
        let barsPath = UIBezierPath()
        let width = calculateBarWidth(points: points, width: barsLayer.bounds.width - padding.horizontal)

        barsLayer.lineWidth = onePixel // set minimal line width. All pixels inside will be filled
        let pixelShift = onePixel / 2 // pixel shift, because line drawing by center of x/y

        let reverse = pathDirection == .bottom
        let drawCap = lineCapStyle == .round

        let sign: CGFloat = reverse ? -1 : 1

        for (_, point) in points.enumerated() {
            let startX: CGFloat =
                switch barPosition {
                case .start:
                    point.x + pixelShift
                case .center:
                    point.x - width / 2 + pixelShift
                case .end:
                    point.x - width + pixelShift
                }

            let tooSmallForArc = reverse ? ((zeroY - point.y) < width) : ((point.y - zeroY) < width)
            let placeForArc = drawCap && !tooSmallForArc ? (width / 2) * sign : 0
            let low = zeroY + placeForArc
            let high = point.y - placeForArc

            barsPath.move(to: CGPoint(x: startX, y: low))
            barsPath.addLine(to: CGPoint(x: startX, y: high))

            let centerX = startX + width / 2 - onePixel / 2
            let endX = startX + width - onePixel

            if drawCap {
                barsPath.addArc(
                    withCenter: CGPoint(x: centerX, y: high),
                    radius: !tooSmallForArc ? width / 2 - onePixel : 0,
                    startAngle: -Double.pi,
                    endAngle: 0,
                    clockwise: reverse
                )
            }

            barsPath.addLine(to: CGPoint(x: endX, y: high))
            barsPath.addLine(to: CGPoint(x: endX, y: low))

            if drawCap {
                barsPath.addArc(
                    withCenter: CGPoint(x: centerX, y: low),
                    radius: !tooSmallForArc ? width / 2 - onePixel : 0,
                    startAngle: 0,
                    endAngle: Double.pi,
                    clockwise: reverse
                )
            }

            barsPath.close()
        }
        return barsPath.cgPath
    }

    override func corrected(points: [CGPoint], newCount _: Int) -> [CGPoint] {
        points
    }

    override func transformAnimation(
        oldPath: CGPath,
        new: [CGPoint],
        duration: CFTimeInterval,
        timingFunction: CAMediaTimingFunction?
    )
        -> CAAnimation {
        guard points.count != new.count || morphingAnimationDisabled else {
            return super.transformAnimation(
                oldPath: oldPath,
                new: new,
                duration: duration,
                timingFunction: timingFunction
            )
        }
        // when count is different we animated hiding old bars and show new
        let downOldPath = path(points: absolute(points: points).map { CGPoint(x: $0.x, y: zeroY) })

        let downNewPath = path(points: new.map { CGPoint(x: $0.x, y: zeroY) })
        let newPath = path(points: new)

        let halfDuration = duration / 2

        let downAnimation = ShapeHelper.animation(
            keyPath: "path",
            from: oldPath,
            to: downOldPath,
            duration: duration,
            timingFunction: timingFunction
        )
        downAnimation.duration = halfDuration

        let upAnimation = ShapeHelper.animation(
            keyPath: "path",
            from: downNewPath,
            to: newPath,
            duration: duration,
            timingFunction: timingFunction
        )
        upAnimation.duration = halfDuration
        upAnimation.beginTime = halfDuration

        let group = CAAnimationGroup()

        group.duration = duration
        group.animations = [downAnimation, upAnimation]

        return group
    }

    override func updateFrame(in bounds: CGRect, duration: CFTimeInterval?, timingFunction: CAMediaTimingFunction?) {
        super.updateFrame(in: bounds, duration: duration, timingFunction: timingFunction)

        maskLayer.bounds = barsLayer.bounds
    }

    // MARK: Functions

    func calculateBarWidth(points: [CGPoint], width _: CGFloat) -> CGFloat {
        guard points.count > 3 else {
            return width
        }
        var maxWidth = width

        // if gap more than 2 pixels, we can add gap between bars
        let minimumWithGap = 2 * onePixel
        // don't use for calculation first and last points.
        // Because sometimes for 1day chart it's position too close to next point
        for index in 1 ..< (points.count - 3) {
            // distance between two bars
            let gap = points[index + 1].x - points[index].x
            // if there is not enough space, set smallest width
            if gap < minimumWithGap {
                maxWidth = onePixel
                break
            }
            maxWidth = min(gap - onePixel, maxWidth)
        }
        return max(maxWidth, 2 * onePixel)
    }
}
