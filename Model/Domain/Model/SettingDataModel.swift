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
    let repository = UserDefaultRepository()

    /// カレントコンテキスト
    var currentContext: String {
        get {
            return repository.get(key: .currentContext)
        }
        set(value) {
            repository.set(key: .currentContext, value: value)
        }
    }

    /// 自動スクロールインターバル
    var autoScrollInterval: Float {
        get {
            return Float(repository.get(key: .autoScrollInterval))
        }
        set(value) {
            repository.set(key: .autoScrollInterval, value: Double(value))
        }
    }

    /// メニュー順序
    var menuOrder: [UserOperation] {
        get {
            return repository.get(key: .menuOrder)
        }
        set(value) {
            repository.set(key: .menuOrder, value: value)
        }
    }

    /// ページ履歴保存日数
    var pageHistorySaveCount: Int {
        return repository.get(key: .pageHistorySaveCount)
    }

    /// 閲覧履歴保存日数
    var commonHistorySaveCount: Int {
        return repository.get(key: .commonhistorySaveCount)
    }

    /// 検索履歴保存日数
    var searchHistorySaveCount: Int {
        return repository.get(key: .searchHistorySaveCount)
    }

    private init() {}

    /// ユーザーデフォルト初期化
    func initialize() {
        repository.initialize()
    }

    /// メニュー順序初期化
    func initializeMenuOrder() {
        repository.set(key: .menuOrder, value: ModelConst.UD.MENU_ORDER)
    }
}
