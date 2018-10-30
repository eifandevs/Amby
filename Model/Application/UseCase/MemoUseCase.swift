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

/// メモユースケース
public final class MemoUseCase {
    public static let s = MemoUseCase()

    /// 閲覧通知用RX
    public let rx_memoUseCaseDidRequestRead = PublishSubject<String>()

    private init() {}

    public func delete() {
        MemoDataModel.s.delete()
    }

    public func read(id: String) {
        rx_memoUseCaseDidRequestRead.onNext(id)
    }

    public func delete(memo: Memo) {
        MemoDataModel.s.delete(memo: memo)
    }

    public func select() -> [Memo] {
        return MemoDataModel.s.select()
    }

    public func select(id: String) -> [Memo] {
        return MemoDataModel.s.select(id: id)
    }
}
