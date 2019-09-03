//
//  MemoViewControllerViewModel.swift
//  Amby
//
//  Created by tenma on 2018/11/01.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Entity
import Foundation
import Model

final class MemoViewControllerViewModel {
    private var memo: Memo!

    init(memo: Memo) {
        self.memo = memo
    }

    func getMemoText() -> String {
        return memo.text
    }

    /// 送信
    func update(text: String) {
        if text.count > 0 {
            _ = UpdateMemoUseCase().exe(memo: memo, text: text)
        } else {
            _ = DeleteMemoUseCase().exe(memo: memo)
        }
    }
}
