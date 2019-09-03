//
//  DeleteMemoUseCase.swift
//  Model
//
//  Created by tenma.i on 2019/08/07.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class DeleteMemoUseCase {

    private var memoDataModel: MemoDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        memoDataModel = MemoDataModel.s
    }

    public func exe() {
        memoDataModel.delete()
    }

    public func exe(memo: Memo) {
        if memoDataModel.select(id: memo.id) != nil {
            log.debug("delete memo. memo: \(memo)")
            memoDataModel.delete(memo: memo)
        } else {
            log.debug("not delete memo")
        }
    }
}
