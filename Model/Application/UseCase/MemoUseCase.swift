//
//  MemoUseCase.swift
//  Model
//
//  Created by tenma on 2018/10/29.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

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

    private init() {}

    public func delete() {
        MemoDataModel.s.delete()
    }

    public func open(memo: Memo) {
        rx_action.onNext(.present(memo: memo))
    }

    public func close() {
        rx_action.onNext(.close)
    }

    public func insert(memo: Memo) {
        MemoDataModel.s.insert(memo: memo)
    }

    public func update(memo: Memo, text: String) {
        // 新規作成の場合は、データが存在しないのでinsertに変更する
        if MemoDataModel.s.select(id: memo.id) != nil {
            log.debug("memo update. before: \(memo.text) after: \(text)")
            MemoDataModel.s.update(memo: memo, text: text)
        } else {
            memo.text = text
            log.debug("memo insert. memo: \(memo)")
            MemoDataModel.s.insert(memo: memo)
        }
    }

    public func invertLock(memo: Memo) {
        MemoDataModel.s.invertLock(memo: memo)
    }

    public func delete(memo: Memo) {
        if MemoDataModel.s.select(id: memo.id) != nil {
            log.debug("delete memo. memo: \(memo)")
            MemoDataModel.s.delete(memo: memo)
        } else {
            log.debug("not delete memo")
        }
    }

    public func select() -> [Memo] {
        return MemoDataModel.s.select()
    }

    public func select(id: String) -> Memo? {
        return MemoDataModel.s.select(id: id)
    }
}
