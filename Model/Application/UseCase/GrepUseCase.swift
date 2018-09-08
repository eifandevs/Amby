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
public final class GrepUseCase {
    public static let s = GrepUseCase()

    /// グレップ開始通知用RX
    public let rx_grepUseCaseDidBeginGreping = PublishSubject<()>()
    /// グレップリクエスト通知用RX
    public let rx_grepUseCaseDidRequestGrep = PublishSubject<String>()

    private init() {}

    /// グレップ開始
    public func begin() {
        rx_grepUseCaseDidBeginGreping.onNext(())
    }

    /// グレップリクエスト
    public func grep(word: String) {
        rx_grepUseCaseDidRequestGrep.onNext(word)
    }
}
