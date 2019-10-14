//
//  InvertLockMemoUseCase.swift
//  Model
//
//  Created by tenma.i on 2019/08/09.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class InvertLockMemoUseCase {

    private var memoDataModel: MemoDataModelProtocol!
    let disposeBag = DisposeBag()

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        memoDataModel = MemoDataModel.s
    }

    public func exe(memo: Memo) {
        ChallengeLocalAuthenticationUseCase().exe()
            .observeOn(MainScheduler.instance) // realmのスレッドエラー対応
            .subscribe { [weak self] result in
                guard let `self` = self, let result = result.element else { return }
                if case .success(_) = result {
                    self.memoDataModel.invertLock(memo: memo)
                }
            }
            .disposed(by: disposeBag)
    }
}
