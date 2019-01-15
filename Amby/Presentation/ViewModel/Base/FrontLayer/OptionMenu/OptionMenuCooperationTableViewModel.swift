//
//  OptionMenuCooperationTableViewModel.swift
//  Amby
//
//  Created by tenma on 2018/11/12.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import Model

final class OptionMenuCooperationTableViewModel {
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
