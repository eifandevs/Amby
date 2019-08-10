//
//  SelectMemoUseCase.swift
//  Model
//
//  Created by tenma.i on 2019/08/09.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class SelectMemoUseCase {

    private var memoDataModel: MemoDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        memoDataModel = MemoDataModel.s
    }

    public func exe() -> [Memo] {
        return memoDataModel.select()
    }

    public func exe(id: String) -> Memo? {
        return memoDataModel.select(id: id)
    }
}
