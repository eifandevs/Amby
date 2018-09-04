//
//  UserDefaultRepository.swift
//  Model
//
//  Created by tenma on 2018/09/02.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

public class UserDefaultRepository {
    public init() {}

    /// 閲覧履歴保存日数
    public var commonHistorySaveCount: Int {
        return UserDefaults.standard.integer(forKey: ModelConst.KEY.COMMON_HISTORY_SAVE_COUNT)
    }

    /// カレントコンテキスト
    public var currentContext: String {
        get {
            return UserDefaults.standard.string(forKey: ModelConst.KEY.CURRENT_CONTEXT)!
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: ModelConst.KEY.CURRENT_CONTEXT)
        }
    }

    /// 自動スクロールインターバル
    public var autoScrollInterval: Float {
        get {
            return UserDefaults.standard.float(forKey: ModelConst.KEY.AUTO_SCROLL_INTERVAL)
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: ModelConst.KEY.AUTO_SCROLL_INTERVAL)
        }
    }

    /// ページ履歴保存日数
    public var pageHistorySaveCount: Int {
        return UserDefaults.standard.integer(forKey: ModelConst.KEY.PAGE_HISTORY_SAVE_COUNT)
    }

    /// 検索履歴保存日数
    public var searchHistorySaveCount: Int {
        return UserDefaults.standard.integer(forKey: ModelConst.KEY.SEARCH_HISTORY_SAVE_COUNT)
    }

    /// ユーザーデフォルト初期値設定
    public func setup() {
        UserDefaults.standard.register(defaults: [
            ModelConst.KEY.CURRENT_CONTEXT: ModelConst.UD.CURRENT_CONTEXT,
            ModelConst.KEY.AUTO_SCROLL_INTERVAL: ModelConst.UD.AUTO_SCROLL,
            ModelConst.KEY.COMMON_HISTORY_SAVE_COUNT: ModelConst.UD.COMMON_HISTORY_SAVE_COUNT,
            ModelConst.KEY.PAGE_HISTORY_SAVE_COUNT: ModelConst.UD.PAGE_HISTORY_SAVE_COUNT,
            ModelConst.KEY.SEARCH_HISTORY_SAVE_COUNT: ModelConst.UD.SEARCH_HISTORY_SAVE_COUNT,
        ])
    }

    /// ユーザーデフォルト初期化
    public func initialize() {
        UserDefaults.standard.set(ModelConst.UD.CURRENT_CONTEXT, forKey: ModelConst.KEY.CURRENT_CONTEXT)
        UserDefaults.standard.set(ModelConst.UD.AUTO_SCROLL, forKey: ModelConst.KEY.AUTO_SCROLL_INTERVAL)
        UserDefaults.standard.set(ModelConst.UD.COMMON_HISTORY_SAVE_COUNT, forKey: ModelConst.KEY.COMMON_HISTORY_SAVE_COUNT)
        UserDefaults.standard.set(ModelConst.UD.PAGE_HISTORY_SAVE_COUNT, forKey: ModelConst.KEY.PAGE_HISTORY_SAVE_COUNT)
        UserDefaults.standard.set(ModelConst.UD.SEARCH_HISTORY_SAVE_COUNT, forKey: ModelConst.KEY.SEARCH_HISTORY_SAVE_COUNT)
    }
}
