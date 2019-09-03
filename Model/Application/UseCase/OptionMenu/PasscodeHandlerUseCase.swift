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

    /// passcode setting usecase
    let usecase = GetPassCodeSettingUseCase()

    private init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
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
        if usecase.isRegisterdPasscode {
            if usecase.isInputPasscode {
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
