//
//  Date+Extend.swift
//  Qas
//
//  Created by temma on 2017/11/20.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

extension Date {
    func toString(format: String = AppConst.APP_DATE_FORMAT) -> String {
        let formatter = DateFormatter()
        let jaLocale = Locale(identifier: AppConst.APP_LOCALE)
        formatter.locale = jaLocale
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }
}
