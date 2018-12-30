//
//  TrendUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum TrendUseCaseAction {
    case load(url: String)
}

/// トレンドユースケース
public final class TrendUseCase {
    public static let s = TrendUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<TrendUseCaseAction>()
    
    private init() {}

    /// トレンドページ表示
    public func load() {
        rx_action.onNext(.load(url: ModelConst.URL.TREND_HOME_URL))
    }
}
