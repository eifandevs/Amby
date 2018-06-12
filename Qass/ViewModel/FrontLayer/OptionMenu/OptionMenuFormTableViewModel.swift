//
//  OptionMenuFormTableViewModel.swift
//  Qas
//
//  Created by temma on 2017/12/24.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

final class OptionMenuFormTableViewModel {
    let cellHeight = AppConst.FRONT_LAYER_TABLE_VIEW_CELL_HEIGHT
    /// セル情報
    var rows: [Row] = []

    /// セル数
    var cellCount: Int {
        return rows.count
    }

    init() {
        rows = FormDataModel.s.select().map({ Row(data: $0) })
    }

    /// セル情報取得
    func getRow(indexPath: IndexPath) -> Row {
        return rows[indexPath.row]
    }

    /// セル削除
    /// セルの有無を返却する
    func removeRow(indexPath: IndexPath, row: Row) {
        rows.remove(at: indexPath.row)
        // モデルから削除
        FormDataModel.s.delete(forms: [row.data])
    }

    /// セル情報
    struct Row {
        let data: Form
    }
}
