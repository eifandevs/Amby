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

enum MemoDataModelError {
    case get
    case store
    case delete
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
        }
    }
}

final class MemoDataModel {
    static let s = MemoDataModel()

    /// メモ登録通知用RX
    let rx_memoDataModelDidInsert = PublishSubject<()>()
    /// メモ登録失敗通知用RX
    let rx_memoDataModelDidInsertFailure = PublishSubject<()>()
    /// メモ削除通知用RX
    let rx_memoDataModelDidDelete = PublishSubject<()>()
    /// メモ全削除通知用RX
    let rx_memoDataModelDidDeleteAll = PublishSubject<()>()
    /// メモ削除失敗通知用RX
    let rx_memoDataModelDidDeleteFailure = PublishSubject<()>()
    /// メモ情報取得失敗通知用RX
    let rx_memoDataModelDidGetFailure = PublishSubject<()>()
    /// エラー通知用RX
    let rx_error = PublishSubject<MemoDataModelError>()
    
    /// db repository
    let repository = DBRepository()

    private init() {}

    /// insert Memos
    func insert(memo: Memo) {
        let result = repository.insert(data: [memo])
        
        switch result {
        case .success(_):
            rx_memoDataModelDidInsert.onNext(())
        case .failure(_):
            rx_error.onNext(.store)
        }
    }

    /// select all memo
    func select() -> [Memo] {
        let result = repository.select(type: Memo.self)
        
        switch result {
        case let .success(memos):
            return memos as! [Memo]
        case .failure(_):
            rx_error.onNext(.get)
            return []
        }
    }

    /// select memo
    func select(id: String) -> Memo? {
        if let memos = repository.select(type: Memo.self) as? [Memo] {
            return memos.filter({ $0.id == id }).first ?? nil
        } else {
            log.error("fail to select memo")
            return nil
        }
    }

    /// update Memo
    func update(memo: Memo, text: String) {
        _ = repository.update {
            memo.text = text
        }
    }

    // lock or unlock
    func invertLock(memo: Memo) {
        _ = repository.update {
            memo.isLocked = !memo.isLocked
        }
    }

    /// delete Memos
    func delete() {
        // 削除対象が指定されていない場合は、すべて削除する
        if repository.delete(data: select()) {
            rx_memoDataModelDidDeleteAll.onNext(())
        } else {
            rx_memoDataModelDidDeleteFailure.onNext(())
        }
    }

    /// delete Memos
    func delete(memo: Memo) {
        if repository.delete(data: [memo]) {
            rx_memoDataModelDidDelete.onNext(())
        } else {
            rx_memoDataModelDidDeleteFailure.onNext(())
        }
    }
}
