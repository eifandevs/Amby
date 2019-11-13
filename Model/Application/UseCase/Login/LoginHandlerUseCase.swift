//
//  LoginHandlerUseCase.swift
//  Model
//
//  Created by tenma.i on 2019/11/13.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum LoginHandlerUseCaseAction {
    case begin
}

/// グレップユースケース
public final class LoginHandlerUseCase {
    public static let s = LoginHandlerUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<LoginHandlerUseCaseAction>()

    private init() {
    }

    /// ログイン開始
    public func begin() {
        rx_action.onNext(.begin)
    }
}
