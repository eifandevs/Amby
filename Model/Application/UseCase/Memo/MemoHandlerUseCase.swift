//
//   MemoHandlerUseCase.swift
//  Model
//
//  Created by tenma on 2018/10/29.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Entity
import Foundation
import RxCocoa
import RxSwift

public enum  MemoHandlerUseCaseAction {
    case present(memo: Memo)
    case update
}

/// メモユースケース
public final class  MemoHandlerUseCase {
    public static let s =  MemoHandlerUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<MemoHandlerUseCaseAction>()

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
                default: break
                }
            }
            .disposed(by: disposeBag)
    }

    public func open(memo: Memo) {
        rx_action.onNext(.present(memo: memo))
    }
}
