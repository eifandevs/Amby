//
//  PasscodeUseCase.swift
//  Model
//
//  Created by tenma on 2018/10/21.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

enum PasscodeUseCaseAction {
    case present
    case confirm
}

enum PasscodeUseCaseError {
    case notRegistered
}

extension PasscodeUseCaseError: ModelError {
    var message: String {
        switch self {
        case .notRegistered:
            return MessageConst.NOTIFICATION.PASSCODE_NOT_REGISTERED
        }
    }
}

/// パスコードユースケース
public final class PasscodeUseCase {
    public static let s = PasscodeUseCase()

    /// アクション通知用RX
    let rx_action = PublishSubject<PasscodeUseCaseAction>()
    /// エラー通知用RX
    let rx_error = PublishSubject<PasscodeUseCaseError>()

    /// パスコード
    public var rootPasscode: String {
        get {
            return SettingDataModel.s.rootPasscode
        }
        set(value) {
            SettingDataModel.s.rootPasscode = value
        }
    }

    /// パスコート認証済みフラグ
    public var isInputPasscode: Bool {
        get {
            return AuthDataModel.s.isInputPasscode
        }
        set(value) {
            AuthDataModel.s.isInputPasscode = value
        }
    }

    /// パスコード登録済みフラグ
    public var isRegisterdPasscode: Bool {
        return !rootPasscode.isEmpty
    }

    private init() {}

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
        if PasscodeUseCase.s.isRegisterdPasscode {
            if PasscodeUseCase.s.isInputPasscode {
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
