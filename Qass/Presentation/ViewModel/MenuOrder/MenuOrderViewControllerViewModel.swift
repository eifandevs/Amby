//
//  MenuOrderViewControllerViewModel.swift
//  Qass
//
//  Created by tenma on 2018/10/15.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import Model

final class MenuOrderViewControllerViewModel {
    // セル情報
    struct Row {
        let operation: UserOperation
    }

    // 高さ
    let cellHeight = AppConst.FRONT_LAYER.TABLE_VIEW_MENU_ORDER_CELL_HEIGHT
    // 数
    var cellCount: Int {
        return rows.count
    }

    private var rows = SettingUseCase.s.menuOrder.map { Row(operation: $0) }

    func getRow(index: Int) -> Row {
        return rows[index]
    }
}
