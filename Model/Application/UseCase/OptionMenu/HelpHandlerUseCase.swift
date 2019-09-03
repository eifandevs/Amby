//
//  HelpHandlerUseCase.swift
//  Amby
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum HelpHandlerUseCaseAction {
    case present(title: String, message: String)
}

/// ヘルプユースケース
public final class HelpHandlerUseCase {
    public static let s = HelpHandlerUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<HelpHandlerUseCaseAction>()

    private init() {}

    /// ヘルプ画面表示
    public func open(title: String, message: String) {
        rx_action.onNext(.present(title: title, message: message))
    }
}
