//
//  LocalAuthenticationHandlerUseCase.swift
//  Model
//
//  Created by tenma on 2018/10/21.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum LocalAuthenticationHandlerUseCaseAction {
    case present
    case confirm
}

enum LocalAuthenticationHandlerUseCaseError {
    case notRegistered
}

extension LocalAuthenticationHandlerUseCaseError: ModelError {
    var message: String {
        switch self {
        case .notRegistered:
            return MessageConst.NOTIFICATION.PASSCODE_NOT_REGISTERED
        }
    }
}

/// パスコードユースケース
public final class LocalAuthenticationHandlerUseCase {
    public static let s = LocalAuthenticationHandlerUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<LocalAuthenticationHandlerUseCaseAction>()
    /// エラー通知用RX
    let rx_error = PublishSubject<LocalAuthenticationHandlerUseCaseError>()

    /// passcode setting usecase
    let usecase = GetLocalAuthenticationSettingUseCase()

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

    /// エラー通知
    func noticeNotRegistered() {
        rx_error.onNext(.notRegistered)
    }
}
