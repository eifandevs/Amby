//
//  UpdateMemoUseCase.swift
//  Model
//
//  Created by tenma.i on 2019/08/09.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Entity
import RxCocoa
import RxSwift

public final class UpdateMemoUseCase {

    private var memoDataModel: MemoDataModelProtocol!

    public init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        memoDataModel = MemoDataModel.s
    }

    public func exe(memo: Memo, text: String) {
        // 新規作成の場合は、データが存在しないのでinsertに変更する
        if memoDataModel.select(id: memo.id) != nil {
            log.debug("memo update. before: \(memo.text) after: \(text)")
            memoDataModel.update(memo: memo, text: text)
        } else {
            memo.text = text
            log.debug("memo insert. memo: \(memo)")
            memoDataModel.insert(memo: memo)
        }
    }
}
