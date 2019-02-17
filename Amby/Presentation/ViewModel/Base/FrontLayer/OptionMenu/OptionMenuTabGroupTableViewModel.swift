//
//  OptionMenuTabGroupTableViewModel.swift
//  Amby
//
//  Created by tenma on 2019/02/12.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import Model

final class OptionMenuTabGroupTableViewModel {
    // セル情報
    struct Row {
        let title: String
        let groupContext: String
        var isFront: Bool
    }

    // セル
    var rows: [Row] = TabUseCase.s.pageGroupList.groups.map({ Row(title: $0.title, groupContext: $0.groupContext, isFront: TabUseCase.s.pageGroupList.currentGroupContext == $0.groupContext) })

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
