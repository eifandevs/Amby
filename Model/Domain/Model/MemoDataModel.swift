//
//  MemoDataModel.swift
//  Model
//
//  Created by tenma on 2018/10/29.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RealmSwift
import RxCocoa
import RxSwift

enum MemoDataModelAction {
    case insert
    case delete
    case deleteAll
}

enum MemoDataModelError {
    case get
    case store
    case delete
    case update
}

extension MemoDataModelError: ModelError {
    var message: String {
        switch self {
        case .get:
            return MessageConst.NOTIFICATION.GET_MEMO_ERROR
        case .store:
            return MessageConst.NOTIFICATION.STORE_MEMO_ERROR
        case .delete:
            return MessageConst.NOTIFICATION.DELETE_MEMO_ERROR
        case .update:
            return MessageConst.NOTIFICATION.UPDATE_MEMO_ERROR
        }
    }
}

final class MemoDataModel {
    static let s = MemoDataModel()
    
    /// アクション通知用RX
    let rx_action = PublishSubject<MemoDataModelAction>()
    /// エラー通知用RX
    let rx_error = PublishSubject<MemoDataModelError>()

    /// db repository
    let repository = DBRepository()

    private init() {}

    /// insert Memos
    func insert(memo: Memo) {
        let result = repository.insert(data: [memo])
        if case .success = result {
            rx_action.onNext(.insert)
        } else {
            rx_error.onNext(.store)
        }
    }

    /// select all memo
    func select() -> [Memo] {
        let result = repository.select(type: Memo.self)

        if case let .success(memos) = result {
            return memos as! [Memo]
        } else {
            rx_error.onNext(.get)
            return []
        }
    }

    /// select memo
    func select(id: String) -> Memo? {
        let result = repository.select(type: Memo.self)

        if case let .success(memos) = result {
            return (memos as! [Memo]).filter({ $0.id == id }).first ?? nil
        } else {
            rx_error.onNext(.get)
            return nil
        }
    }

    /// update Memo
    func update(memo: Memo, text: String) {
        let result = repository.update {
            memo.text = text
        }

        if case .failure = result {
            rx_error.onNext(.update)
        }
    }

    // lock or unlock
    func invertLock(memo: Memo) {
        let result = repository.update {
            memo.isLocked = !memo.isLocked
        }

        if case .failure = result {
            rx_error.onNext(.update)
        }
    }

    /// delete Memos
    func delete() {
        // 削除対象が指定されていない場合は、すべて削除する
        let result = repository.delete(data: select())

        if case .success = result {
            rx_action.onNext(.deleteAll)
        } else {
            rx_error.onNext(.delete)
        }
    }

    /// delete Memos
    func delete(memo: Memo) {
        let result = repository.delete(data: [memo])

        if case .success = result {
            rx_action.onNext(.delete)
        } else {
            rx_error.onNext(.delete)
        }
    }
}
