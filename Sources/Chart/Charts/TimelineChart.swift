//
//  TimelineChart.swift
//
//  Created by Sun on 2021/11/29.
//

import UIKit

import UIExtensions

// MARK: - ChartTimelineItem

public struct ChartTimelineItem {
    // MARK: Properties

    let text: String
    let timestamp: TimeInterval

    // MARK: Lifecycle

    public init(text: String, timestamp: TimeInterval) {
        self.text = text
        self.timestamp = timestamp
    }
}

// MARK: - TimelineChart

class TimelineChart: Chart {
    // MARK: Properties

    private var texts = [ChartText]()

    private var timelineTexts = [String]()
    private var timelinePositions = [CGPoint]()
    private let horizontalLines = ChartGridLines()

    private var configuration: ChartConfiguration?

    // MARK: Lifecycle

    init(configuration: ChartConfiguration? = nil) {
        super.init(frame: .zero)

        add(horizontalLines)

        apply(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Overridden Functions

    override func layoutSubviews() {
        updateTextInsets()

        super.layoutSubviews()
    }

    // MARK: Functions

    @discardableResult
    func apply(configuration: ChartConfiguration?) -> Self {
        self.configuration = configuration

        if let configuration {
            horizontalLines.gridType = .horizontal
            horizontalLines.width = configuration.borderWidth
            horizontalLines.strokeColor = configuration.borderColor
            horizontalLines.set(points: [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 0)])
        }

        return self
    }

    func set(texts: [String], positions: [CGPoint]) {
        for text in self.texts {
            text.layer.removeFromSuperlayer()
        }
        self.texts.removeAll()

        timelineTexts = texts
        timelinePositions = positions

        for item in texts {
            let text = ChartText()
            text.set(text: item)
            if let configuration {
                text.textColor = configuration.timelineTextColor
                text.font = configuration.timelineFont
            }
            self.texts.append(text)
            add(text)
        }
    }

    func updateTextInsets() {
        guard let configuration else {
            return
        }

        for i in (0 ..< timelineTexts.count).reversed() {
            var currentPosition = ShapeHelper.convertRelative(
                point: timelinePositions[i],
                size: bounds.size,
                padding: .zero
            )
            var insets = configuration.timelineInsets

            if i == texts.count - 1 { // check last element position
                // check text does not go beyond bounds
                let textSize = timelineTexts[i].size(
                    containerWidth: layer.bounds.width,
                    font: configuration.timelineFont
                )

                let width = textSize.width + configuration.timelineInsets.left + configuration.timelineInsets.right
                if (currentPosition.x + width) > layer.bounds.width {
                    currentPosition.x = layer.bounds.width - width
                }

                insets.left += currentPosition.x
                insets.top += currentPosition.y
            } else {
                let nextPositionX = texts[i + 1].insets.left

                insets.left += currentPosition.x
                insets.top += currentPosition.y
                insets.right += bounds.size.width - nextPositionX
            }

            texts[i].insets = insets
        }
    }

    func setTexts(hidden: Bool) {
        for text in texts {
            text.layer.isHidden = hidden
        }
    }
}
