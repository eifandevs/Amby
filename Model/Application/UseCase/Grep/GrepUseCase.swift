//
//  GrepUseCase.swift
//  Amby
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum GrepUseCaseAction {
    case begin
    case request(word: String)
    case finish
    case previous(index: Int)
    case next(index: Int)
}

/// グレップユースケース
public final class GrepUseCase {
    public static let s = GrepUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<GrepUseCaseAction>()

    /// grep counter
    private var grepResultCount: (current: Int, total: Int) = (0, 0)

    private init() {}

    /// グレップ開始
    public func begin() {
        rx_action.onNext(.begin)
    }

    /// グレップ完了
    public func finish(hitNum: Int) {
        grepResultCount = (0, hitNum)
        rx_action.onNext(.finish)
    }

    /// グレップリクエスト
    public func grep(word: String) {
        if !word.isEmpty {
            rx_action.onNext(.request(word: word))
        }
    }

    /// 前に移動
    public func previous() {
        guard grepResultCount.current > 0 else { return }
        grepResultCount.current -= 1
        rx_action.onNext(.previous(index: grepResultCount.current))
    }

    /// 次に移動
    public func next() {
        let index = grepResultCount.current == grepResultCount.total ? 0 : grepResultCount.current + 1
        grepResultCount.current = index
        rx_action.onNext(.next(index: grepResultCount.current))
    }
}
