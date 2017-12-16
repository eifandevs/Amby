//
//  OptionMenuTableViewModel.swift
//  Qas
//
//  Created by temma on 2017/12/16.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

class OptionMenuTableViewModel {
    let cellHeight = AppConst.FRONT_LAYER_TABLE_VIEW_CELL_HEIGHT
    var cellCount: Int {
        return rows.count
    }
    let overViewMargin = AppConst.FRONT_LAYER_OVER_VIEW_MARGIN
    let rows: [Row] = [
        Row(imageName: R.image.option_menu_history.name, title: AppConst.OPTION_MENU_HISTORY),
        Row(imageName: R.image.option_menu_form.name, title: AppConst.OPTION_MENU_FORM),
        Row(imageName: R.image.optionmenu_favorite.name, title: AppConst.OPTION_MENU_BOOKMARK),
        Row(imageName: R.image.option_menu_setting.name, title: AppConst.OPTION_MENU_SETTING),
        Row(imageName: R.image.optionmenu_app.name, title: AppConst.OPTION_MENU_APP_INFORMATION)
    ]
    
    /// セル情報取得
    func getRow(indexPath: IndexPath) -> Row {
        return rows[indexPath.row]
    }
    
    /// セル情報
    struct Row {
        let imageName: String
        let title: String
    }
}
