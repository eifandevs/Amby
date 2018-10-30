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

    /// db repository
    let repository = DBRepository()

    private init() {}

    /// insert Memos
    func insert(memo: Memo) {
        if repository.insert(data: [memo]) {
            rx_memoDataModelDidInsert.onNext(())
        } else {
            rx_memoDataModelDidInsertFailure.onNext(())
        }
    }

    /// select all memo
    func select() -> [Memo] {
        if let memos = repository.select(type: Memo.self) as? [Memo] {
            return memos
        } else {
            log.error("fail to select memo")
            return []
        }
    }

    /// select memo
    func select(id: String) -> [Memo] {
        if let memos = repository.select(type: Memo.self) as? [Memo] {
            return memos.filter({ $0.id == id })
        } else {
            log.error("fail to select memo")
            return []
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
