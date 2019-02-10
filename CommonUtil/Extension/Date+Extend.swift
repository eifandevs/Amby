//
//  Date+Extend.swift
//  Qas
//
//  Created by temma on 2017/11/20.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

public extension Date {
    public func toString(format: String = "yyyyMMdd") -> String {
        let formatter = DateFormatter()
        let jaLocale = Locale(identifier: "ja_JP")
        formatter.locale = jaLocale
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    public var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }

    public var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }

    public var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }

    public var month: Int {
        return Calendar.current.component(.month, from: self)
    }

    public var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }

    /// インターバル(h)取得
    public var intervalHourSinceNow: Double {
        return -(timeIntervalSinceNow / 60 / 60)
    }
}
