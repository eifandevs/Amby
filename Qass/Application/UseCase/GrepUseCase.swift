//
//  GrepUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// グレップユースケース
final class GrepUseCase {

    static let s = GrepUseCase()

    /// グレップ開始通知用RX
    let rx_grepUseCaseDidBeginGreping = PublishSubject<()>()
    /// グレップリクエスト通知用RX
    let rx_grepUseCaseDidRequestGrep = PublishSubject<String>()

    /// グレップ開始
    func begin() {
        rx_grepUseCaseDidBeginGreping.onNext(())
    }

    /// グレップリクエスト
    func grep(word: String) {
        rx_grepUseCaseDidRequestGrep.onNext(word)
    }
}
