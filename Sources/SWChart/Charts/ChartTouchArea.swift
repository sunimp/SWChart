//
//  ChartTouchArea.swift
//  SWChart
//
//  Created by Sun on 2024/8/15.
//

import UIKit

// MARK: - ITouchAreaDelegate

protocol ITouchAreaDelegate: AnyObject {
    func touchDown()
    func select(at: Int)
    func touchUp()
}

// MARK: - ChartTouchArea

class ChartTouchArea: Chart {
    // MARK: Properties

    weak var delegate: ITouchAreaDelegate?

    private var gestureRecognizer: UILongPressGestureRecognizer?
    private var verticalLine = ChartGridLines()
    private var pointCircle = ChartCircle()
    private var points = [CGPoint]()
    private var last: Int?

    private var curvePadding: UIEdgeInsets = .zero

    private var configuration: ChartConfiguration?

    // MARK: Lifecycle

    init(configuration: ChartConfiguration? = nil) {
        super.init(frame: .zero)

        createPanGestureRecognizer()
        add(verticalLine)
        add(pointCircle)

        if let configuration {
            apply(configuration: configuration)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Overridden Functions

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        updateUI()
    }

    // MARK: Functions

    @discardableResult
    func apply(configuration: ChartConfiguration) -> Self {
        self.configuration = configuration

        if configuration.isInteractive {
            curvePadding = configuration.curvePadding

            verticalLine.width = configuration.touchLineWidth
            verticalLine.gridType = .vertical
            verticalLine.retinaCorrected = false
            verticalLine.padding = configuration.curvePadding

            pointCircle.radius = configuration.touchCircleRadius

            var padding = configuration.curvePadding
            if configuration.showIndicatorArea {
                padding.bottom += configuration.indicatorHeight
            } else {
                verticalLine.bottomInset = configuration.curveBottomInset
            }

            pointCircle.insets = padding

            updateUI()
        }

        return self
    }

    func set(points: [CGPoint]) {
        self.points = points
    }

    /// The Pan Gesture
    private func createPanGestureRecognizer() {
        gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture:)))
        if let gestureRecognizer {
            addGestureRecognizer(gestureRecognizer)
            gestureRecognizer.minimumPressDuration = 0.05
            gestureRecognizer.delaysTouchesBegan = false
        }
    }

    @objc
    private func handlePanGesture(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: self)

        switch gesture.state {
        case .began:
            delegate?.touchDown()
            update(at: location)

        case .changed:
            update(at: location)

        default:
            stop()
        }
    }

    private func findNearest(position: CGFloat) -> Int? {
        guard bounds.width > 0 else {
            return nil
        }

        let position = (position - curvePadding.left) / (bounds.width - curvePadding.horizontal)
        for i in 0 ..< points.count {
            if position == points[i].x { // x equal point.x . Return point
                return i
            }
            if position < points[i].x { // x less than point.x
                guard (i - 1) >= 0 else { // When no previous point, return current
                    return i
                }
                // calculate which point is nearest to x
                let halfInterval = (points[i].x - points[i - 1].x) / 2
                let nearPrevious = (points[i - 1].x + halfInterval) > position

                return nearPrevious ? (i - 1) : i
            }
            guard (i + 1) < points.count else { // When x more than point.x and no next point, return current
                return i
            }
            // else go next loop
        }
        return nil
    }

    private func update(at location: CGPoint) {
        guard let index = findNearest(position: location.x), last != index else {
            return
        }
        last = index

        verticalLine.set(points: [CGPoint(x: points[index].x, y: 1)], animated: false)
        pointCircle.set(points: [points[index]], animated: false)
        delegate?.select(at: index)
    }

    private func stop() {
        last = nil

        verticalLine.set(points: [])
        pointCircle.set(points: [])
        delegate?.touchUp()
    }

    private func updateUI() {
        verticalLine.strokeColor = configuration?.touchLineColor ?? .clear
        pointCircle.backgroundColor = configuration?.touchCircleColor
    }
}

// MARK: UIGestureRecognizerDelegate

extension ChartTouchArea: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_: UIGestureRecognizer, shouldRequireFailureOf _: UIGestureRecognizer) -> Bool {
        true
    }

    public func gestureRecognizer(_: UIGestureRecognizer, shouldReceive _: UITouch) -> Bool {
        true
    }
}
