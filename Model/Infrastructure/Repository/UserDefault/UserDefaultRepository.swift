//
//  UserDefaultRepository.swift
//  Model
//
//  Created by tenma on 2018/09/02.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    static let currentContext = DefaultsKey<String>(ModelConst.KEY.CURRENT_CONTEXT, defaultValue: ModelConst.UD.CURRENT_CONTEXT)
    static let rootPasscode = DefaultsKey<String>(ModelConst.KEY.ROOT_PASSCODE, defaultValue: ModelConst.UD.ROOT_PASSCODE)
    static let lastReportDate = DefaultsKey<Date>(ModelConst.KEY.LAST_REPORT_DATE, defaultValue: ModelConst.UD.LAST_REPORT_DATE)
    static let autoScrollInterval = DefaultsKey<Double>(ModelConst.KEY.AUTO_SCROLL_INTERVAL, defaultValue: ModelConst.UD.AUTO_SCROLL_INTERVAL)
    static let menuOrder = DefaultsKey<[UserOperation]>(ModelConst.KEY.MENU_ORDER, defaultValue: ModelConst.UD.MENU_ORDER)
    static let commonhistorySaveCount = DefaultsKey<Int>(ModelConst.KEY.COMMON_HISTORY_SAVE_COUNT, defaultValue: ModelConst.UD.COMMON_HISTORY_SAVE_COUNT)
    static let searchHistorySaveCount = DefaultsKey<Int>(ModelConst.KEY.SEARCH_HISTORY_SAVE_COUNT, defaultValue: ModelConst.UD.SEARCH_HISTORY_SAVE_COUNT)
    static let pageHistorySaveCount = DefaultsKey<Int>(ModelConst.KEY.PAGE_HISTORY_SAVE_COUNT, defaultValue: ModelConst.UD.PAGE_HISTORY_SAVE_COUNT)
}

class UserDefaultRepository {
    init() {}

    func get<T>(key: DefaultsKey<T>) -> T {
        return Defaults[key]
    }

    func set<T>(key: DefaultsKey<T>, value: T) {
        Defaults[key] = value
    }

    /// ユーザーデフォルト初期化
    func initialize() {
        if let bundleId = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleId)
        } else {
            log.error("userdefault initialize error")
        }
    }
}
