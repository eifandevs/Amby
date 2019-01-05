//
//  OpenSourceUseCase.swift
//  Model
//
//  Created by tenma on 2018/09/12.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum OpenSourceUseCaseAction {
    case present
}

/// オープンソースユースケース
public final class OpenSourceUseCase {
    public static let s = OpenSourceUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<OpenSourceUseCaseAction>()

    private init() {}

    /// オープンソース画面表示
    public func open() {
        rx_action.onNext(.present)
    }
}
