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

/// トレンドユースケース
final class TrendUseCase {

    static let s = TrendUseCase()

    /// ロードリクエスト通知用RX
    let rx_trendUseCaseDidRequestLoad = PublishSubject<String>()

    private init() {}

    /// トレンドページ表示
    func load() {
        rx_trendUseCaseDidRequestLoad.onNext(HttpConst.URL.TREND_HOME_URL)
    }
}
