//
//  OpenSourceHandlerUseCase.swift
//  Model
//
//  Created by tenma on 2018/09/12.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum OpenSourceHandlerUseCaseAction {
    case present
}

/// オープンソースユースケース
public final class OpenSourceHandlerUseCase {
    public static let s = OpenSourceHandlerUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<OpenSourceHandlerUseCaseAction>()

    private init() {}

    /// オープンソース画面表示
    public func open() {
        rx_action.onNext(.present)
    }
}
