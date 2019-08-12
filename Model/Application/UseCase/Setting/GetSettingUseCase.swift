//
//  GetSettingUseCase.swift
//  Amby
//
//  Created by tenma on 2018/08/27.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// 設定ユースケース
public final class GetSettingUseCase {
    public static let s = GetSettingUseCase()

    /// 閲覧履歴保存日数
    public var commonHistorySaveCount: Int {
        return settingDataModel.commonHistorySaveCount
    }

    /// 自動スクロールインターバル
    public var autoScrollInterval: Float {
        get {
            return settingDataModel.autoScrollInterval
        }
        set(value) {
            settingDataModel.autoScrollInterval = value
        }
    }

    /// 新規ウィンドウ許諾フラグ
    public var newWindowConfirm: Bool {
        get {
            return settingDataModel.newWindowConfirm
        }
        set(value) {
            settingDataModel.newWindowConfirm = value
        }
    }

    /// メニュー順序
    public var menuOrder: [UserOperation] {
        get {
            return settingDataModel.menuOrder
        }
        set(value) {
            settingDataModel.menuOrder = value
        }
    }

    /// 検索履歴保存日数
    public var searchHistorySaveCount: Int {
        return settingDataModel.searchHistorySaveCount
    }

    public func initialize() {
        settingDataModel.initialize()
    }

    public func initializeMenuOrder() {
        settingDataModel.initializeMenuOrder()
    }

    private var settingDataModel: SettingDataModelProtocol!

    private init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        settingDataModel = SettingDataModel.s
    }
}
