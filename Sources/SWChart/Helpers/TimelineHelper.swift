//
//  TimelineHelper.swift
//  SWChart
//
//  Created by Sun on 2024/8/15.
//

import Foundation

// MARK: - ITimelineHelper

public protocol ITimelineHelper {
    func timestamps(startTimestamp: TimeInterval, endTimestamp: TimeInterval, separateHourlyInterval: Int)
        -> [TimeInterval]
    func text(timestamp: TimeInterval, separateHourlyInterval: Int, dateFormatter: DateFormatter) -> String
}

// MARK: - TimelineHelper

public class TimelineHelper: ITimelineHelper {
    // MARK: Properties

    private let day = 24
    private let month = 30 * 24
    private let year = 12 * 30 * 24

    // MARK: Lifecycle

    public init() { }

    // MARK: Functions

    /// return timestamps in minutes for grid vertical lines
    public func timestamps(
        startTimestamp: TimeInterval,
        endTimestamp: TimeInterval,
        separateHourlyInterval: Int
    )
        -> [TimeInterval] {
        var timestamps = [TimeInterval]()

        let lastDate = Date(timeIntervalSince1970: endTimestamp)
        var lastTimestamp: TimeInterval =
            switch separateHourlyInterval {
            case 0 ..< day: lastDate.startOfHour?.timeIntervalSince1970 ?? endTimestamp
            case day ..< month: lastDate.startOfDay.timeIntervalSince1970
            case month ..< year: lastDate.startOfMonth?.timeIntervalSince1970 ?? endTimestamp
            default: lastDate.startOfYear?.timeIntervalSince1970 ?? endTimestamp
            }

        while lastTimestamp >= startTimestamp {
            timestamps.append(lastTimestamp)
            lastTimestamp = stepBack(for: lastTimestamp, separateHourlyInterval: separateHourlyInterval)
        }

        return timestamps.sorted()
    }

    public func text(timestamp: TimeInterval, separateHourlyInterval: Int, dateFormatter: DateFormatter) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: date)

        switch separateHourlyInterval {
        case 0 ..< day:
            guard let hour = components.hour else {
                return "--"
            }
            return String("\(hour)")

        case 24 ... (24 * 3): // half week for show minimum 2 values
            dateFormatter.setLocalizedDateFormatFromTemplate("E")
            return dateFormatter.string(from: date)

        case (24 * 3 + 1) ..< month:
            guard let day = components.day else {
                return "--"
            }
            return String("\(day)")

        case month ..< year:
            dateFormatter.setLocalizedDateFormatFromTemplate("MMM")
            return dateFormatter.string(from: date)

        default:
            dateFormatter.setLocalizedDateFormatFromTemplate("YYYY")
            return dateFormatter.string(from: date)
        }
    }

    private func stepBack(for timestamp: TimeInterval, separateHourlyInterval: Int) -> TimeInterval {
        let hourInSeconds: TimeInterval = 60 * 60
        switch separateHourlyInterval {
        case 0 ..< 24: return timestamp - TimeInterval(separateHourlyInterval) * hourInSeconds
        case 24 ..< (24 * 30): return timestamp - TimeInterval(separateHourlyInterval) * hourInSeconds
        default:
            let date = Date(timeIntervalSince1970: timestamp)
            let ago = date.startOfMonth(ago: separateHourlyInterval / (24 * 30))
            return ago?.timeIntervalSince1970 ?? timestamp
        }
    }
}
