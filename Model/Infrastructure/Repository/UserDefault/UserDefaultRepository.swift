//
//  UserDefaultRepository.swift
//  Model
//
//  Created by tenma on 2018/09/02.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

class UserDefaultRepository {
    init() {}

    /// 閲覧履歴保存日数
    var commonHistorySaveCount: Int {
        return UserDefaults.standard.integer(forKey: ModelConst.KEY.COMMON_HISTORY_SAVE_COUNT)
    }

    /// カレントコンテキスト
    var currentContext: String {
        get {
            return UserDefaults.standard.string(forKey: ModelConst.KEY.CURRENT_CONTEXT)!
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: ModelConst.KEY.CURRENT_CONTEXT)
        }
    }

    /// メニュー順序
    var menuOrder: [UserOperation] {
        get {
            let rawOrder: [Int] = (UserDefaults.standard.array(forKey: ModelConst.KEY.MENU_ORDER)!).map { $0 as! Int }
            return rawOrder.map { UserOperation(rawValue: $0)! }
        }
        set(value) {
            UserDefaults.standard.set(value.map { $0.rawValue }, forKey: ModelConst.KEY.MENU_ORDER)
        }
    }

    /// 自動スクロールインターバル
    var autoScrollInterval: Float {
        get {
            return UserDefaults.standard.float(forKey: ModelConst.KEY.AUTO_SCROLL_INTERVAL)
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: ModelConst.KEY.AUTO_SCROLL_INTERVAL)
        }
    }

    /// ページ履歴保存日数
    var pageHistorySaveCount: Int {
        return UserDefaults.standard.integer(forKey: ModelConst.KEY.PAGE_HISTORY_SAVE_COUNT)
    }

    /// 検索履歴保存日数
    var searchHistorySaveCount: Int {
        return UserDefaults.standard.integer(forKey: ModelConst.KEY.SEARCH_HISTORY_SAVE_COUNT)
    }

    /// ユーザーデフォルト初期値設定
    func setup() {
        UserDefaults.standard.register(defaults: [
            ModelConst.KEY.CURRENT_CONTEXT: ModelConst.UD.CURRENT_CONTEXT,
            ModelConst.KEY.AUTO_SCROLL_INTERVAL: ModelConst.UD.AUTO_SCROLL,
            ModelConst.KEY.COMMON_HISTORY_SAVE_COUNT: ModelConst.UD.COMMON_HISTORY_SAVE_COUNT,
            ModelConst.KEY.PAGE_HISTORY_SAVE_COUNT: ModelConst.UD.PAGE_HISTORY_SAVE_COUNT,
            ModelConst.KEY.SEARCH_HISTORY_SAVE_COUNT: ModelConst.UD.SEARCH_HISTORY_SAVE_COUNT,
            ModelConst.KEY.MENU_ORDER: ModelConst.UD.MENU_ORDER
        ])
    }

    /// メニュー順序初期化
    func initializeMenuOrder() {
        UserDefaults.standard.set(ModelConst.UD.MENU_ORDER, forKey: ModelConst.KEY.MENU_ORDER)
    }

    /// ユーザーデフォルト初期化
    func initialize() {
        UserDefaults.standard.set(ModelConst.UD.CURRENT_CONTEXT, forKey: ModelConst.KEY.CURRENT_CONTEXT)
        UserDefaults.standard.set(ModelConst.UD.AUTO_SCROLL, forKey: ModelConst.KEY.AUTO_SCROLL_INTERVAL)
        UserDefaults.standard.set(ModelConst.UD.COMMON_HISTORY_SAVE_COUNT, forKey: ModelConst.KEY.COMMON_HISTORY_SAVE_COUNT)
        UserDefaults.standard.set(ModelConst.UD.PAGE_HISTORY_SAVE_COUNT, forKey: ModelConst.KEY.PAGE_HISTORY_SAVE_COUNT)
        UserDefaults.standard.set(ModelConst.UD.SEARCH_HISTORY_SAVE_COUNT, forKey: ModelConst.KEY.SEARCH_HISTORY_SAVE_COUNT)
        UserDefaults.standard.set(ModelConst.UD.MENU_ORDER, forKey: ModelConst.KEY.MENU_ORDER)
    }
}
