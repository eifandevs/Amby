//
//  PassCodeSettingUseCase.swift
//  Model
//
//  Created by tenma.i on 2019/08/16.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// 設定ユースケース
public final class GetLocalAuthenticationSettingUseCase {

    /// パスコード
    public var rootPasscode: String {
        get {
            return settingDataModel.rootPasscode
        }
        set(value) {
            settingDataModel.rootPasscode = value
        }
    }

    /// パスコート認証済みフラグ
    public var isInputPasscode: Bool {
        get {
            return settingDataModel.isInputPasscode
        }
        set(value) {
            settingDataModel.isInputPasscode = value
        }
    }

    /// パスコード登録済みフラグ
    public var isRegisterdPasscode: Bool {
        return !rootPasscode.isEmpty
    }

    private var settingDataModel: SettingDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        settingDataModel = SettingDataModel.s
    }
}
