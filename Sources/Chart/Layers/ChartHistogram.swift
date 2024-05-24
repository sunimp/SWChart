import UIKit

class ChartHistogram: ChartPointsObject {
    private let wrapperLayer = CALayer()
    private let positiveBars = ChartBars()
    private let negativeBars = ChartBars()

    var barPosition: ChartBarPosition = .center
    var verticalSplitValue: CGFloat = 0.5 {
        didSet {
            updateFrame(in: wrapperLayer.bounds, duration: nil, timingFunction: nil)
        }
    }

    override var layer: CALayer {
        wrapperLayer
    }

    public var backgroundColor: UIColor? {
        didSet {
            positiveBars.layer.backgroundColor = backgroundColor?.cgColor
            negativeBars.layer.backgroundColor = backgroundColor?.cgColor
        }
    }

    public var positiveStrokeColor: UIColor = .clear {
        didSet {
            positiveBars.strokeColor = positiveStrokeColor
        }
    }

    public var negativeStrokeColor: UIColor = .clear {
        didSet {
            negativeBars.strokeColor = negativeStrokeColor
        }
    }

    public var barWidth: CGFloat = 4 {
        didSet {
            positiveBars.width = barWidth
            negativeBars.width = barWidth
            positiveBars.layer.displayIfNeeded()
            negativeBars.layer.displayIfNeeded()
        }
    }

    public var positiveBarFillColor: UIColor? = nil {
        didSet {
            positiveBars.barFillColor = positiveBarFillColor
        }
    }

    public var negativeBarFillColor: UIColor? = nil {
        didSet {
            negativeBars.barFillColor = negativeBarFillColor
        }
    }

    override var padding: UIEdgeInsets {
        didSet {
            positiveBars.padding = UIEdgeInsets(
                top: padding.top,
                left: padding.left,
                bottom: .zero,
                right: padding.right
            )
            negativeBars.padding = UIEdgeInsets(
                top: .zero,
                left: padding.left,
                bottom: padding.bottom,
                right: padding.right
            )
        }
    }

    override init() {
        super.init()

        for item in [positiveBars, negativeBars] {
            item.layer.shouldRasterize = true
            item.layer.rasterizationScale = UIScreen.main.scale

            item.strokeColor = .clear
            item.barFillColor = nil
            item.barPosition = barPosition
            item.lineCapStyle = .square

            wrapperLayer.addSublayer(item.layer)
        }

        negativeBars.pathDirection = .top

        reversePoint = false
    }

    override func corrected(points: [CGPoint], newCount _: Int) -> [CGPoint] {
        points
    }

    override func absolute(points: [CGPoint]) -> [CGPoint] {
        points
    }

    private func split(points: [CGPoint]) -> (positive: [CGPoint], negative: [CGPoint]) {
        var positive = [CGPoint]()
        var negative = [CGPoint]()

        for point in points {
            if point.y >= verticalSplitValue {
                let y = (point.y - verticalSplitValue) / (1 - verticalSplitValue)
                positive.append(CGPoint(x: point.x, y: y))
            } else {
                let y: CGFloat = point.y / verticalSplitValue
                negative.append(CGPoint(x: point.x, y: y))
            }
        }

        return (positive: positive, negative: negative)
    }

    override func update(start _: Bool, old: [CGPoint], new: [CGPoint], duration: CFTimeInterval?, timingFunction _: CAMediaTimingFunction?) {
        let oldPoints = split(points: old)
        let newPoints = split(points: new)

        // if nothing changes, but current timestamp. We must use morphing for histogram
        positiveBars.morphingAnimationDisabled = oldPoints.positive.count != newPoints.positive.count
        negativeBars.morphingAnimationDisabled = oldPoints.negative.count != newPoints.negative.count

        positiveBars.set(points: newPoints.positive, animated: duration != nil)
        negativeBars.set(points: newPoints.negative, animated: duration != nil)
    }

    override func updateFrame(in bounds: CGRect, duration: CFTimeInterval?, timingFunction: CAMediaTimingFunction?) {
        super.updateFrame(in: bounds, duration: duration, timingFunction: timingFunction)

        let frame = wrapperLayer.bounds
        let realAreaHeight = frame.height - padding.height
        let realPositiveHeight = realAreaHeight * (1 - verticalSplitValue)
        let realNegativeHeight = realAreaHeight - realPositiveHeight

        let positive = CGRect(
            x: frame.origin.x,
            y: frame.origin.y,
            width: frame.width,
            height: realPositiveHeight + padding.top
        )

        let negative = CGRect(
            x: frame.origin.x,
            y: frame.origin.y + positive.height,
            width: frame.width,
            height: realNegativeHeight + padding.bottom
        )

        positiveBars.updateFrame(in: positive, duration: duration, timingFunction: timingFunction)
        negativeBars.updateFrame(in: negative, duration: duration, timingFunction: timingFunction)
    }
}
