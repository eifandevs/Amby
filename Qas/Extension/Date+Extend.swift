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
}
