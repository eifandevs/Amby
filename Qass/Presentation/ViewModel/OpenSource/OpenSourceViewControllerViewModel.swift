//
//  OpenSourceViewControllerViewModel.swift
//  Qass
//
//  Created by tenma on 2018/09/17.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

final class OpenSourceViewControllerViewModel {
    // セル情報
    struct Row {
        let title: String
        let description: String
    }

    // 高さ
    let cellHeight = AppConst.FRONT_LAYER.TABLE_VIEW_CELL_HEIGHT
    // 数
    var cellCount: Int {
        return rows.count
    }

    let rows = ResourceUtil().licenseList
}
