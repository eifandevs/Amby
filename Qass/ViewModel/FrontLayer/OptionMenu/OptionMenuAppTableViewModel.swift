//
//  OptionMenuAppTableViewModel.swift
//  Qas
//
//  Created by temma on 2017/12/24.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

final class OptionMenuAppTableViewModel {
    // セル情報
    struct Row {
        let cellType: CellType
    }

    enum CellType: Int {
        case app
        case copyright

        var title: String {
            switch self {
            case .app: return AppConst.APP_INFORMATION_APP
            case .copyright: return AppConst.APP_INFORMATION_COPYRIGHT
            }
        }
    }

    // セル
    let rows = [
        Row(cellType: .app),
        Row(cellType: .copyright)
    ]

    // 高さ
    let cellHeight = AppConst.FRONT_LAYER_TABLE_VIEW_CELL_HEIGHT
    // 数
    var cellCount: Int {
        return rows.count
    }

    /// セル情報取得
    func getRow(indexPath: IndexPath) -> Row {
        return rows[indexPath.row]
    }
}
