//
//  OptionMenuTabGroupTableViewModel.swift
//  Amby
//
//  Created by tenma on 2019/02/12.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation

final class OptionMenuTabGroupTableViewModel {
    // セル情報
    struct Row {
        let title: String
    }

    // セル
    let rows = [
        Row(title: AppConst.OPTION_MENU.DONATION),
        Row(title: AppConst.OPTION_MENU.DEVELOPMENT)
    ]

    // 高さ
    let cellHeight = AppConst.FRONT_LAYER.TABLE_VIEW_CELL_HEIGHT
    // 数
    var cellCount: Int {
        return rows.count
    }

    /// セル情報取得
    func getRow(indexPath: IndexPath) -> Row {
        return rows[indexPath.row]
    }
}
