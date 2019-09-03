//
//  PolicyHandlerUseCase.swift
//  Model
//
//  Created by tenma on 2018/09/09.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum PolicyHandlerUseCaseAction {
    case load
}

/// ポリシーユースケース
public final class PolicyHandlerUseCase {
    public static let s = PolicyHandlerUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<PolicyHandlerUseCaseAction>()

    private init() {}

    /// ライセンス表示
    public func open() {
        rx_action.onNext(.load)
    }
}
