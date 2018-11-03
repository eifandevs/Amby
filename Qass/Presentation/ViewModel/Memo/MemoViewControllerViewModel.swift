//
//  MemoViewControllerViewModel.swift
//  Qass
//
//  Created by tenma on 2018/11/01.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

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
            MemoUseCase.s.update(memo: memo, text: text)
        } else {
            MemoUseCase.s.delete(memo: memo)
        }
    }
}
