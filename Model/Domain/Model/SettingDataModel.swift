//
//  SettingDataModel.swift
//  Qas
//
//  Created by tenma on 2018/04/19.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

protocol SettingDataModelProtocol {
    var rootPasscode: String { get set }
    var lastReportDate: Date { get set }
    var autoScrollInterval: Float { get set }
    var menuOrder: [UserOperation] { get set }
    var newWindowConfirm: Bool { get set }
    var pageHistorySaveCount: Int { get }
    var commonHistorySaveCount: Int { get }
    var searchHistorySaveCount: Int { get }
    func initialize()
    func initializeMenuOrder()
}

final class SettingDataModel: SettingDataModelProtocol {
    static let s = SettingDataModel()
    private let repository = UserDefaultRepository()

    /// パスコード
    var rootPasscode: String {
        get {
            // 復号化
            let code = repository.get(key: .rootPasscode)
            return code.bytes.count == 0 ? "" : EncryptService.decrypt(data: code)
        }
        set(value) {
            // 暗号化
            let code = EncryptService.encrypt(value: value)
            repository.set(key: .rootPasscode, value: code)
        }
    }

    /// 最終お問い合わせ日
    var lastReportDate: Date = UserDefaultRepository().get(key: .lastReportDate) {
        didSet {
            repository.set(key: .lastReportDate, value: lastReportDate)
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
    var menuOrder: [UserOperation] = UserDefaultRepository().get(key: .menuOrder) {
        didSet {
            repository.set(key: .menuOrder, value: menuOrder)
        }
    }

    /// 新規ウィンドウ許諾フラグ
    var newWindowConfirm: Bool = UserDefaultRepository().get(key: .newWindowConfirm) {
        didSet {
            repository.set(key: .newWindowConfirm, value: newWindowConfirm)
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
