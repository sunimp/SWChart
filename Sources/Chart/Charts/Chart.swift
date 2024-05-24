import UIKit

class Chart: UIView {
    var chartObjects = [IChartObject]()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonInit()
    }

    private func commonInit() {
        clipsToBounds = true
    }

    func add(_ object: IChartObject) {
        chartObjects.append(object)
        layer.addSublayer(object.layer)

        layer.layoutIfNeeded()
        object.layer.setNeedsLayout()
    }

    func remove(_ object: IChartObject) {
        guard let index = chartObjects.firstIndex(where: { $0 === object }) else {
            return
        }
        chartObjects.remove(at: index)
        object.layer.removeFromSuperlayer()
    }

    func replace(_ oldObject: IChartObject, by object: IChartObject) {
        guard let objectIndex = chartObjects.firstIndex(where: { $0 === oldObject }),
              let layerIndex = layer.sublayers?.firstIndex(of: oldObject.layer)
        else {
            print("Can't found object")
            return
        }

        chartObjects[objectIndex] = object
        layer.replaceSublayer(oldObject.layer, with: object.layer)

        object.layer.setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // If the view is animating apply the animation to the sublayer
        CATransaction.begin()

        let animation = layer.animation(forKey: "position")
        if let duration = animation?.duration {
            CATransaction.setAnimationDuration(duration)
            CATransaction.setAnimationTimingFunction(animation?.timingFunction)
        } else {
            CATransaction.disableActions()
        }
        for object in chartObjects {
            object.updateFrame(in: bounds,
                               duration: animation?.duration,
                               timingFunction: animation?.timingFunction)
        }

        CATransaction.commit()
    }
}
