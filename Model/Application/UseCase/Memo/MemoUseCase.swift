//
//  MemoUseCase.swift
//  Model
//
//  Created by tenma on 2018/10/29.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Entity
import Foundation
import RxCocoa
import RxSwift

public enum MemoUseCaseAction {
    case present(memo: Memo)
    case update
}

/// メモユースケース
public final class MemoUseCase {
    public static let s = MemoUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<MemoUseCaseAction>()

    /// models
    private var memoDataModel: MemoDataModelProtocol!

    /// Observable自動解放
    private let disposeBag = DisposeBag()

    private init() {
        setupProtocolImpl()
        setupRx()
    }

    private func setupProtocolImpl() {
        memoDataModel = MemoDataModel.s
    }

    private func setupRx() {
        memoDataModel.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }
                switch action {
                case .insert, .update, .delete, .deleteAll, .invertLock:
                    self.rx_action.onNext(.update)
                }
            }
            .disposed(by: disposeBag)
    }

    public func open(memo: Memo) {
        rx_action.onNext(.present(memo: memo))
    }

    public func invertLock(memo: Memo) {
        if PasscodeUseCase.s.authentificationChallenge() {
            memoDataModel.invertLock(memo: memo)
        }
    }
}
