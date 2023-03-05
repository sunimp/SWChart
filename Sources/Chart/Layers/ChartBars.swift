import UIKit

enum ChartBarPosition {
    case start, center, end
}

class ChartBars: ChartPointsObject {
    private let onePixel: CGFloat = 1 / UIScreen.main.scale

    private let barsLayer = CAShapeLayer()
    private let maskLayer = CALayer()

    var barPosition: ChartBarPosition = .center
    var morphingAnimationDisabled = false

    override var layer: CALayer {
        barsLayer
    }

    public var backgroundColor: UIColor? {
        didSet {
            barsLayer.backgroundColor = backgroundColor?.cgColor
        }
    }

    override public var strokeColor: UIColor {
        didSet {
            barsLayer.strokeColor = strokeColor.cgColor
        }
    }
    override var fillColor: UIColor {
        didSet {
            barsLayer.fillColor = fillColor.cgColor
            barsLayer.displayIfNeeded()
        }
    }
    override public var width: CGFloat {
        didSet {
            barsLayer.displayIfNeeded()
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

    override init() {
        super.init()

        barsLayer.shouldRasterize = true
        barsLayer.rasterizationScale = UIScreen.main.scale
        barsLayer.mask = maskLayer
        barsLayer.fillColor = nil

        maskLayer.anchorPoint = .zero
        maskLayer.backgroundColor = UIColor.black.cgColor
    }

    override func appearingAnimation(new: [CGPoint], duration: CFTimeInterval, timingFunction: CAMediaTimingFunction?) -> CAAnimation? {
        switch animationStyle {
        case .verticalGrowing:
            return super.appearingAnimation(new: new, duration: duration, timingFunction: timingFunction)
        case .strokeEnd:
            maskLayer.bounds = barsLayer.bounds

            let startBounds = CGRect(x: 0, y: 0, width: 0, height: barsLayer.bounds.height)
            let boundsAnimation = ShapeHelper.animation(keyPath: "bounds", from: startBounds, to: barsLayer.bounds, duration: duration, timingFunction: timingFunction)
            maskLayer.add(boundsAnimation, forKey: strokeAnimationKey)
            return CABasicAnimation(keyPath: animationKey)
        }
    }

    override public func set(points: [CGPoint], animated: Bool = false) {
        super.set(points: points, animated: animated)
    }

    override func path(points: [CGPoint]) -> CGPath {
        let barsPath = UIBezierPath()
        let width = calculateBarWidth(points: points, width: barsLayer.bounds.width)
        barsPath.lineWidth = 1 / UIScreen.main.scale        // set minimal line width. All pixels inside will be filled
        let pixelShift = barsPath.lineWidth / 2             // pixel shift, because line drawing by center of x/y

        let reverse = pathDirection == .bottom
        let drawCap = lineCapStyle == .round

        let verticalPixelShift = reverse ? -pixelShift : pixelShift
        let verticalFullShift = reverse ? -width : width

        points.enumerated().forEach { index, point in
            var startX: CGFloat
            switch barPosition {
            case .start:
                startX = point.x + pixelShift
            case .center:
                startX = point.x - width / 2 + pixelShift
            case .end:
                startX = point.x - width + pixelShift
            }

            let low = zeroY + verticalFullShift / 2 + 2 * verticalPixelShift
            let high = point.y - verticalFullShift / 2 - verticalPixelShift

            barsPath.move(to: CGPoint(x: startX, y: low))
            barsPath.addLine(to: CGPoint(x: startX, y: high))
            if drawCap {
                barsPath.addArc(withCenter: CGPoint(x: startX + width / 2, y: high), radius: width / 2 , startAngle: -Double.pi, endAngle: 0, clockwise: reverse)
            }
            let endX = startX + width // - barsPath.lineWidth

            barsPath.addLine(to: CGPoint(x: endX, y: high))
            barsPath.addLine(to: CGPoint(x: endX, y: low))
            if drawCap {
                barsPath.addArc(withCenter: CGPoint(x: startX + width / 2, y: low), radius: width / 2, startAngle: 0, endAngle: Double.pi, clockwise: reverse)
            }
            barsPath.close()
        }
        return barsPath.cgPath
    }

    func calculateBarWidth(points: [CGPoint], width: CGFloat) -> CGFloat {
        guard points.count > 1 else { return width }
        var maxWidth = self.width

        let minimumWithGap = 2 * onePixel                           // if gap more than 2 pixels, we can add gap between bars
        for index in 0..<(points.count - 2) {
            let gap = points[index + 1].x - points[index].x     // distance between two bars
            if gap < minimumWithGap {                           // if there is not enough space, set smallest width
                maxWidth = onePixel
                break
            }
            maxWidth = min(gap - onePixel, maxWidth)
        }
        return max(maxWidth, onePixel)
    }

    override func corrected(points: [CGPoint], newCount: Int) -> [CGPoint] {
        points
    }

    override func transformAnimation(oldPath: CGPath, new: [CGPoint], duration: CFTimeInterval, timingFunction: CAMediaTimingFunction?) -> CAAnimation {
        guard points.count != new.count || morphingAnimationDisabled else {
            return super.transformAnimation(oldPath: oldPath, new: new, duration: duration, timingFunction: timingFunction)
        }
        // when count is different we animated hiding old bars and show new
        let downOldPath = path(points: absolute(points: self.points).map { CGPoint(x: $0.x, y: zeroY) })

        let downNewPath = path(points: new.map { CGPoint(x: $0.x, y: zeroY) })
        let newPath = path(points: new)

        let halfDuration = duration / 2

        let downAnimation = ShapeHelper.animation(keyPath: "path", from: oldPath,
                to: downOldPath,
                duration: duration,
                timingFunction: timingFunction)
        downAnimation.duration = halfDuration

        let upAnimation = ShapeHelper.animation(keyPath: "path", from: downNewPath,
                to: newPath,
                duration: duration,
                timingFunction: timingFunction)
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

}
