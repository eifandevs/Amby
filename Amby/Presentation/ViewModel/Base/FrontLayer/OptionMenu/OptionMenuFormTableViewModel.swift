//
//  OptionMenuFormTableViewModel.swift
//  Amby
//
//  Created by temma on 2017/12/24.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Entity
import Foundation
import Model

final class OptionMenuFormTableViewModel {
    let cellHeight = AppConst.FRONT_LAYER.TABLE_VIEW_CELL_HEIGHT
    /// セル情報
    var rows: [Row] = SelectFormUseCase().exe().map({ Row(data: $0) })

    /// セル数
    var cellCount: Int {
        return rows.count
    }

    /// セル情報取得
    func getRow(indexPath: IndexPath) -> Row {
        return rows[indexPath.row]
    }

    /// セル削除
    func removeRow(indexPath: IndexPath) {
        // モデルから削除
        let row = getRow(indexPath: indexPath)
        FormHandlerUseCase.s.delete(forms: [row.data])
    }

    /// セル情報
    struct Row {
        let data: Form
    }

    /// ロードリクエスト
    func loadRequest(url: String) {
        FormHandlerUseCase.s.load(url: url)
    }

    /// 閲覧リクエスト
    func loadRequest(id: String) {
        FormHandlerUseCase.s.read(id: id)
    }
}
