//
//  SettingUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/27.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// 設定ユースケース
public final class SettingUseCase {
    public static let s = SettingUseCase()

    /// 閲覧履歴保存日数
    public var commonHistorySaveCount: Int {
        return SettingDataModel.s.commonHistorySaveCount
    }

    /// 自動スクロールインターバル
    public var autoScrollInterval: Float {
        get {
            return SettingDataModel.s.autoScrollInterval
        }
        set(value) {
            SettingDataModel.s.autoScrollInterval = value
        }
    }

    /// 検索履歴保存日数
    public var searchHistorySaveCount: Int {
        return SettingDataModel.s.searchHistorySaveCount
    }

    public func initialize() {
        SettingDataModel.s.initialize()
    }

    private init() {}
}
