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
    case close
}

/// メモユースケース
public final class MemoUseCase {
    public static let s = MemoUseCase()

    /// アクション通知用RX
    public let rx_action = PublishSubject<MemoUseCaseAction>()

    /// models
    private var memoDataModel: MemoDataModelProtocol!

    private init() {
        setupProtocolImpl()
    }

    private func setupProtocolImpl() {
        memoDataModel = MemoDataModel.s
    }

    public func delete() {
        memoDataModel.delete()
    }

    public func open(memo: Memo) {
        rx_action.onNext(.present(memo: memo))
    }

    public func close() {
        rx_action.onNext(.close)
    }

    public func insert(memo: Memo) {
        memoDataModel.insert(memo: memo)
    }

    public func update(memo: Memo, text: String) {
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

    public func invertLock(memo: Memo) {
        memoDataModel.invertLock(memo: memo)
    }

    public func delete(memo: Memo) {
        if memoDataModel.select(id: memo.id) != nil {
            log.debug("delete memo. memo: \(memo)")
            memoDataModel.delete(memo: memo)
        } else {
            log.debug("not delete memo")
        }
    }

    public func select() -> [Memo] {
        return memoDataModel.select()
    }

    public func select(id: String) -> Memo? {
        return memoDataModel.select(id: id)
    }
}
