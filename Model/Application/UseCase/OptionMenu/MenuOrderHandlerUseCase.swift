//
//  MenuOrderHandlerUseCase.swift
//  Model
//
//  Created by tenma on 2018/10/11.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum MenuOrderHandlerUseCaseAction {
    case present
}

/// メニューオーダーユースケース
public final class MenuOrderHandlerUseCase {
    public static let s = MenuOrderHandlerUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<MenuOrderHandlerUseCaseAction>()

    private init() {}

    /// 表示
    public func open() {
        rx_action.onNext(.present)
    }
}
