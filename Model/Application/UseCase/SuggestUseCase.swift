//
//  SuggestUseCase.swift
//  Amby
//
//  Created by tenma on 2018/08/23.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum SuggestUseCaseAction {
    case request(word: String)
    case update(suggest: Suggest)
}

/// サジェストユースケース
public final class SuggestUseCase {
    public static let s = SuggestUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<SuggestUseCaseAction>()

    /// models
    private var suggestDataModel: SuggestDataModelProtocol!

    /// Observable自動解放
    let disposeBag = DisposeBag()

    private init() {
        setupProtocolImpl()
        setupRx()
    }

    private func setupProtocolImpl() {
        suggestDataModel = SuggestDataModel.s
    }

    private func setupRx() {
        // サジェスト監視
        suggestDataModel.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self else { return }
                if let action = action.element, case let .update(suggest) = action {
                    self.rx_action.onNext(.update(suggest: suggest))
                }
            }
            .disposed(by: disposeBag)
    }

    /// サジェストリクエスト
    public func suggest(word: String) {
        rx_action.onNext(.request(word: word))
    }

    /// 取得
    public func get(token: String) {
        SuggestDataModel.s.get(token: token)
    }
}
