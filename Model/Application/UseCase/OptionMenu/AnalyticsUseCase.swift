//
//  AnalyticsUseCase.swift
//  Model
//
//  Created by tenma on 2019/03/17.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum AnalyticsUseCaseAction {
    case present
}

/// レポートユースケース
public final class AnalyticsUseCase {
    public static let s = AnalyticsUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<AnalyticsUseCaseAction>()

    /// HTML画面表示
    public func open() {
        rx_action.onNext(.present)
    }
}
