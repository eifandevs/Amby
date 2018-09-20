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
        var expanded: Bool
    }

    // 高さ
    let cellHeight = AppConst.FRONT_LAYER.TABLE_VIEW_LICENSE_CELL_HEIGHT
    // 数
    var cellCount: Int {
        return rows.count
    }

    private var rows = ResourceUtil().licenseList.map { return Row(title: $0.libraryName, description: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", expanded: false) }

    func getRow(index: Int) -> Row {
        return rows[index]
    }

    func invert(index: Int) {
        rows[index].expanded = !rows[index].expanded
    }
}
