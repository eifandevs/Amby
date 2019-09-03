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

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        memoDataModel = MemoDataModel.s
    }

    public func exe(memo: Memo) {
        if PasscodeHandlerUseCase.s.authentificationChallenge() {
            memoDataModel.invertLock(memo: memo)
        }
    }
}
