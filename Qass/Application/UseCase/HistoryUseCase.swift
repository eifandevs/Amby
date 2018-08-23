//
//  HistoryUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// ヒストリーユースケース
final class HistoryUseCase {

    static let s = HistoryUseCase()

    /// ヒストリーバック通知用RX
    let rx_historyUseCaseDidRequestHistoryBack = PublishSubject<()>()
    /// ヒストリーフォワード通知用RX
    let rx_historyUseCaseDidRequestHistoryForward = PublishSubject<()>()
    /// ロードリクエスト通知用RX
    let rx_historyUseCaseDidRequestLoad = PublishSubject<String>()

    /// ヒストリーバック
    func goBack() {
        rx_historyUseCaseDidRequestHistoryBack.onNext(())
    }

    /// ヒストリーフォワード
    func goForward() {
        rx_historyUseCaseDidRequestHistoryForward.onNext(())
    }

    /// ロードリクエスト
    func load(url: String) {
        rx_historyUseCaseDidRequestLoad.onNext(url)
    }

}
