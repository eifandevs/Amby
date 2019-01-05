//
//  MenuOrderUseCase.swift
//  Model
//
//  Created by tenma on 2018/10/11.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum MenuOrderUseCaseAction {
    case present
}

/// メニューオーダーユースケース
public final class MenuOrderUseCase {
    public static let s = MenuOrderUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<MenuOrderUseCaseAction>()

    private init() {}

    /// 表示
    public func open() {
        rx_action.onNext(.present)
    }
}
