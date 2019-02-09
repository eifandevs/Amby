//
//  FormViewControllerViewModel.swift
//  Amby
//
//  Created by tenma on 2018/10/29.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Entity
import Foundation
import Model

final class FormViewControllerViewModel {
    var form: Form!

    // セル情報
    struct Row {
        let value: String
    }

    // 高さ
    let cellHeight = AppConst.FRONT_LAYER.TABLE_VIEW_FORM_CELL_HEIGHT
    // 数
    var cellCount: Int {
        return rows.count
    }

    private var rows: [Row] {
        return form.inputs.map { Row(value: EncryptService.decrypt(data: $0.value)) }
    }

    func getRow(index: Int) -> Row {
        return rows[index]
    }
}
