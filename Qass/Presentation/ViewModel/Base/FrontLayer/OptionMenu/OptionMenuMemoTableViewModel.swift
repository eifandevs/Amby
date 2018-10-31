//
//  OptionMenuMemoTableViewModel.swift
//  Qass
//
//  Created by tenma on 2018/10/31.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import Model

final class OptionMenuMemoTableViewModel {
    // セル情報
    struct Row {
        let memo: Memo
    }

    // セル
    private var rows: [Row] {
        return MemoUseCase.s.select().map { Row(memo: $0) }
    }

    // 高さ
    let cellHeight = AppConst.FRONT_LAYER.TABLE_VIEW_MEMO_CELL_HEIGHT
    // 数
    var cellCount: Int {
        return rows.count
    }

    /// セル情報取得
    func getRow(indexPath: IndexPath) -> Row {
        return rows[indexPath.row]
    }

    /// お問い合わせ表示
    func openMemo(memo: Memo? = nil) {
        MemoUseCase.s.open(memo: memo)
    }
}
