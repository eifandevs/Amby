//
//  MemoDataModel.swift
//  Model
//
//  Created by tenma on 2018/10/29.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Entity
import Foundation
import RxCocoa
import RxSwift

enum MemoDataModelAction {
    case update
    case insert
    case delete
    case deleteAll
    case invertLock
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

protocol MemoDataModelProtocol {
    var rx_action: PublishSubject<MemoDataModelAction> { get }
    var rx_error: PublishSubject<MemoDataModelError> { get }
    func insert(memo: Memo)
    func select() -> [Memo]
    func select(id: String) -> Memo?
    func update(memo: Memo, text: String)
    func invertLock(memo: Memo)
    func delete()
    func delete(memo: Memo)
}

final class MemoDataModel: MemoDataModelProtocol {
    static let s = MemoDataModel()

    /// アクション通知用RX
    let rx_action = PublishSubject<MemoDataModelAction>()
    /// エラー通知用RX
    let rx_error = PublishSubject<MemoDataModelError>()

    /// db repository
    private let repository = DBRepository()

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
        let result = repository.select(Memo.self)

        if case let .success(memos) = result {
            return memos
        } else {
            rx_error.onNext(.get)
            return []
        }
    }

    /// select memo
    func select(id: String) -> Memo? {
        let result = repository.select(Memo.self)

        if case let .success(memos) = result {
            return memos.filter({ $0.id == id }).first ?? nil
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

        if case .success = result {
            rx_action.onNext(.update)
        } else {
            rx_error.onNext(.update)
        }
    }

    // lock or unlock
    func invertLock(memo: Memo) {
        let result = repository.update {
            memo.isLocked = !memo.isLocked
        }

        if case .success = result {
            rx_action.onNext(.invertLock)
        } else {
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
