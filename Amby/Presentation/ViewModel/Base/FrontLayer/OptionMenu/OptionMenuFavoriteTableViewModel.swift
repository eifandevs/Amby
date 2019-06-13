//
//  OptionMenuFavoriteTableViewModel.swift
//  Amby
//
//  Created by temma on 2017/12/21.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Entity
import Foundation
import Model

final class OptionMenuFavoriteTableViewModel {
    let cellHeight = AppConst.FRONT_LAYER.TABLE_VIEW_CELL_HEIGHT
    /// セル情報
    var rows: [Row] = FavoriteUseCase.s.select().map({ Row(data: $0) })

    /// セル数
    var cellCount: Int {
        return rows.count
    }

    /// セル情報取得
    func getRow(indexPath: IndexPath) -> Row {
        return rows[indexPath.row]
    }

    /// セル削除
    /// セルの有無を返却する
    func removeRow(indexPath: IndexPath) {
        let row = getRow(indexPath: indexPath)
        rows.remove(at: indexPath.row)
        // モデルから削除
        FavoriteUseCase.s.delete(favorites: [row.data])
    }

    /// セル情報
    struct Row {
        let data: Favorite
    }

    /// ページ表示要求
    func loadRequest(url: String) {
        FavoriteUseCase.s.load(url: url)
    }
}
