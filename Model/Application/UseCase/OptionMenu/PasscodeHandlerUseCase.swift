//
//  PasscodeHandlerUseCase.swift
//  Model
//
//  Created by tenma on 2018/10/21.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum PasscodeHandlerUseCaseAction {
    case present
    case confirm
}

enum PasscodeHandlerUseCaseError {
    case notRegistered
}

extension PasscodeHandlerUseCaseError: ModelError {
    var message: String {
        switch self {
        case .notRegistered:
            return MessageConst.NOTIFICATION.PASSCODE_NOT_REGISTERED
        }
    }
}

/// パスコードユースケース
public final class PasscodeHandlerUseCase {
    public static let s = PasscodeHandlerUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<PasscodeHandlerUseCaseAction>()
    /// エラー通知用RX
    let rx_error = PublishSubject<PasscodeHandlerUseCaseError>()

    /// models
    private var settingDataModel: SettingDataModelProtocol!
    private var authDataModel: AuthDataModelProtocol!

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
            return authDataModel.isInputPasscode
        }
        set(value) {
            authDataModel.isInputPasscode = value
        }
    }

    /// パスコード登録済みフラグ
    public var isRegisterdPasscode: Bool {
        return !rootPasscode.isEmpty
    }

    private init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        settingDataModel = SettingDataModel.s
        authDataModel = AuthDataModel.s
    }

    /// ライセンス表示
    public func open() {
        rx_action.onNext(.present)
    }

    /// 確認画面表示
    public func confirm() {
        rx_action.onNext(.confirm)
    }

    /// 表示可能判定
    public func authentificationChallenge() -> Bool {
        if isRegisterdPasscode {
            if isInputPasscode {
                return true
            } else {
                confirm()
            }
        } else {
            rx_error.onNext(.notRegistered)
        }
        return false
    }
}
