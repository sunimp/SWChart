//
//  Extensions.swift
//  Chart
//
//  Created by Sun on 2024/8/21.
//

import UIKit

extension Date {
    var startOfHour: Date? {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: self)
        return Calendar.current.date(from: components)
    }

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var startOfMonth: Date? {
        let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
        return Calendar.current.date(from: components)
    }

    var startOfYear: Date? {
        let components = Calendar.current.dateComponents([.year], from: startOfDay)
        return Calendar.current.date(from: components)
    }

    func startOfMonth(ago: Int) -> Date? {
        var components = DateComponents()
        components.month = -ago

        guard let startOfMonth else {
            return nil
        }
        return Calendar.current.date(byAdding: components, to: startOfMonth)
    }
}

public extension Decimal {
    var integerDigitCount: Int {
        var value = abs(self)
        var count = 1
        while value >= 10 {
            value /= 10
            count += 1
        }
        return count
    }

    var cgFloatValue: CGFloat {
        CGFloat(truncating: self as NSNumber)
    }
}

public extension CGFloat {
    var decimalValue: Decimal {
        (self as NSNumber).decimalValue
    }
}
