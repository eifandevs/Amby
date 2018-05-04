//
//  SettingDataModel.swift
//  Qas
//
//  Created by tenma on 2018/04/19.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

final class SettingDataModel {
    static let s = SettingDataModel()

    /// 閲覧履歴保存日数
    var commonHistorySaveCount: Int {
        return UserDefaults.standard.integer(forKey: AppConst.KEY_COMMON_HISTORY_SAVE_COUNT)
    }

    /// カレントコンテキスト
    var currentContext: String {
        get {
            return UserDefaults.standard.string(forKey: AppConst.KEY_CURRENT_CONTEXT)!
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: AppConst.KEY_CURRENT_CONTEXT)
        }
    }

    /// 自動スクロールインターバル
    var autoScrollInterval: Float {
        get {
            return UserDefaults.standard.float(forKey: AppConst.KEY_AUTO_SCROLL_INTERVAL)
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: AppConst.KEY_AUTO_SCROLL_INTERVAL)
        }
    }

    /// ページ履歴保存日数
    var pageHistorySaveCount: Int {
        return UserDefaults.standard.integer(forKey: AppConst.KEY_PAGE_HISTORY_SAVE_COUNT)
    }

    /// 検索履歴保存日数
    var searchHistorySaveCount: Int {
        return UserDefaults.standard.integer(forKey: AppConst.KEY_SEARCH_HISTORY_SAVE_COUNT)
    }

    /// ユーザーデフォルト初期値設定
    func setup() {
        UserDefaults.standard.register(defaults: [
            AppConst.KEY_CURRENT_CONTEXT: AppConst.UD_CURRENT_CONTEXT,
            AppConst.KEY_AUTO_SCROLL_INTERVAL: AppConst.UD_AUTO_SCROLL,
            AppConst.KEY_COMMON_HISTORY_SAVE_COUNT: AppConst.UD_COMMON_HISTORY_SAVE_COUNT,
            AppConst.KEY_PAGE_HISTORY_SAVE_COUNT: AppConst.UD_PAGE_HISTORY_SAVE_COUNT,
            AppConst.KEY_SEARCH_HISTORY_SAVE_COUNT: AppConst.UD_SEARCH_HISTORY_SAVE_COUNT,
        ])
    }

    /// ユーザーデフォルト初期化
    func initialize() {
        UserDefaults.standard.set(AppConst.UD_CURRENT_CONTEXT, forKey: AppConst.KEY_CURRENT_CONTEXT)
        UserDefaults.standard.set(AppConst.UD_AUTO_SCROLL, forKey: AppConst.KEY_AUTO_SCROLL_INTERVAL)
        UserDefaults.standard.set(AppConst.UD_COMMON_HISTORY_SAVE_COUNT, forKey: AppConst.KEY_COMMON_HISTORY_SAVE_COUNT)
        UserDefaults.standard.set(AppConst.UD_PAGE_HISTORY_SAVE_COUNT, forKey: AppConst.KEY_PAGE_HISTORY_SAVE_COUNT)
        UserDefaults.standard.set(AppConst.UD_SEARCH_HISTORY_SAVE_COUNT, forKey: AppConst.KEY_SEARCH_HISTORY_SAVE_COUNT)
    }
}
