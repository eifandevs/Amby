//
//  SettingDataModel.swift
//  Amby
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
    var loginProvider: LoginProvider { get set }
    var newWindowConfirm: Bool { get set }
    var tabSaveCount: Int { get }
    var commonHistorySaveCount: Int { get }
    var searchHistorySaveCount: Int { get }
    var isInputPasscode: Bool { get set }
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
            return code.bytes.count == 0 ? "" : EncryptService.decrypt(dataString: code)
        }
        set(value) {
            // 暗号化
            let code = EncryptService.encrypt(value: value)
            repository.set(key: .rootPasscode, value: code)
        }
    }

    /// 最終お問い合わせ日
    var lastReportDate: Date {
        get {
            return repository.get(key: .lastReportDate)
        }
        set(value) {
            repository.set(key: .lastReportDate, value: value)
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

    /// Login Provider
    var loginProvider: LoginProvider {
        get {
            return LoginProvider(rawValue: repository.get(key: .loginProvider))!
        }
        set(value) {
            repository.set(key: .loginProvider, value: value.rawValue)
        }
    }

    /// メニュー順序
    var menuOrder: [UserOperation] {
        get {
            return repository.get(key: .menuOrder).map { UserOperation(rawValue: $0)! }
        }
        set(value) {
            repository.set(key: .menuOrder, value: value.map { $0.rawValue })
        }
    }

    /// 新規ウィンドウ許諾フラグ
    var newWindowConfirm: Bool {
        get {
            return UserDefaultRepository().get(key: .newWindowConfirm)
        }
        set(value) {
            repository.set(key: .newWindowConfirm, value: value)
        }
    }

    /// ページ履歴保存日数
    var tabSaveCount: Int {
        return repository.get(key: .tabSaveCount)
    }

    /// 閲覧履歴保存日数
    var commonHistorySaveCount: Int {
        return repository.get(key: .commonhistorySaveCount)
    }

    /// 検索履歴保存日数
    var searchHistorySaveCount: Int {
        return repository.get(key: .searchHistorySaveCount)
    }

    /// パスコード認証済みフラグ
    var isInputPasscode = false

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
