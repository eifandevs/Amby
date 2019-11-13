//
//  GrepHandlerUseCase.swift
//  Amby
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum GrepHandlerUseCaseAction {
    case begin
    case request(word: String)
    case finish
    case previous(index: Int)
    case next(index: Int)
}

/// グレップユースケース
public final class GrepHandlerUseCase {
    public static let s = GrepHandlerUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<GrepHandlerUseCaseAction>()

    private init() {
        setupProtocolImpl()
    }

    private var grepDataModel: GrepDataModelProtocol!

    private var grepResultCount: (current: Int, total: Int) {
        get {
            return grepDataModel.grepResultCount
        }
        set(value) {
            grepDataModel.grepResultCount = value
        }
    }

    private func setupProtocolImpl() {
        grepDataModel = GrepDataModel.s
    }

    /// グレップ開始
    public func begin() {
        rx_action.onNext(.begin)
    }

    /// グレップ完了
    public func finish(hitNum: Int) {
        grepDataModel.finish(hitNum: hitNum)
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
        if grepDataModel.previous() {
            rx_action.onNext(.previous(index: grepResultCount.current))
        }
    }

    /// 次に移動
    public func next() {
        grepDataModel.next()
        rx_action.onNext(.next(index: grepResultCount.current))
    }
}
