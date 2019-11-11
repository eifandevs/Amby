//
//  UserDefaultRepository.swift
//  Model
//
//  Created by tenma on 2018/09/02.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

extension DefaultKey {
    static var rootPasscode: DefaultKey<Data> { return DefaultKey<Data>(name: ModelConst.KEY.ROOT_PASSCODE, defaultValue: ModelConst.UD.ROOT_PASSCODE) }
    static var lastReportDate: DefaultKey<Date> { return DefaultKey<Date>(name: ModelConst.KEY.LAST_REPORT_DATE, defaultValue: ModelConst.UD.LAST_REPORT_DATE) }
    static var autoScrollInterval: DefaultKey<Double> { return DefaultKey<Double>(name: ModelConst.KEY.AUTO_SCROLL_INTERVAL, defaultValue: ModelConst.UD.AUTO_SCROLL_INTERVAL) }
    static var menuOrder: DefaultKey<[Int]> { return DefaultKey<[Int]>(name: ModelConst.KEY.MENU_ORDER, defaultValue: ModelConst.UD.MENU_ORDER) }
    static var loginProvider: DefaultKey<Int> { return DefaultKey<Int>(name: ModelConst.KEY.LOGIN_PROVIDER, defaultValue: ModelConst.UD.LOGIN_PROVIDER) }
    static var commonhistorySaveCount: DefaultKey<Int> { return DefaultKey<Int>(name: ModelConst.KEY.COMMON_HISTORY_SAVE_COUNT, defaultValue: ModelConst.UD.COMMON_HISTORY_SAVE_COUNT) }
    static var searchHistorySaveCount: DefaultKey<Int> { return DefaultKey<Int>(name: ModelConst.KEY.SEARCH_HISTORY_SAVE_COUNT, defaultValue: ModelConst.UD.SEARCH_HISTORY_SAVE_COUNT) }
    static var tabSaveCount: DefaultKey<Int> { return DefaultKey<Int>(name: ModelConst.KEY.TAB_SAVE_COUNT, defaultValue: ModelConst.UD.TAB_SAVE_COUNT) }
    static var newWindowConfirm: DefaultKey<Bool> { return DefaultKey<Bool>(name: ModelConst.KEY.NEW_WINDOW_CONFIRM, defaultValue: ModelConst.UD.NEW_WINDOW_CONFIRM) }
}

class UserDefaultRepository {
    init() {}

    func get<T>(key: DefaultKey<T>) -> T {
        return (UserDefaults.standard.value(forKey: key.name) as? T) ?? key.defaultValue
    }

    func set<T>(key: DefaultKey<T>, value: T?) {
        if let value = value {
            UserDefaults.standard.setValue(value, forKey: key.name)
            UserDefaults.standard.synchronize()
        } else {
            UserDefaults.standard.removeObject(forKey: key.name)
        }
    }

    func remove<T>(key: DefaultKey<T>) {
        UserDefaults.standard.removeObject(forKey: key.name)
        UserDefaults.standard.synchronize()
    }

    /// ユーザーデフォルト初期化
    func initialize() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
}
