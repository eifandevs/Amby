//
//  OptionMenuTableViewModel.swift
//  Qas
//
//  Created by temma on 2017/12/16.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

class OptionMenuTableViewModel {
    
    // セル情報
    struct Row {
        let cellType: CellType
    }
    
    /// セルタイプ
    enum CellType {
        case history
        case form
        case favorite
        case setting
        case help
        case app
        
        var imageName: String {
            switch self {
            case .history: return R.image.option_menu_history.name
            case .form: return R.image.option_menu_form.name
            case .favorite: return R.image.optionmenu_favorite.name
            case .setting: return R.image.option_menu_setting.name
            case .help: return R.image.option_menu_help.name
            case .app: return R.image.optionmenu_app.name
            }
        }
        
        var title: String {
            switch self {
            case .history: return AppConst.OPTION_MENU_HISTORY
            case .form: return AppConst.OPTION_MENU_FORM
            case .favorite: return AppConst.OPTION_MENU_BOOKMARK
            case .setting: return AppConst.OPTION_MENU_SETTING
            case .help: return AppConst.OPTION_MENU_HELP
            case .app: return AppConst.OPTION_MENU_APP_INFORMATION
            }
        }
    }
    
    // セル
    let rows = [
        Row(cellType: .history),
        Row(cellType: .form),
        Row(cellType: .favorite),
        Row(cellType: .setting),
        Row(cellType: .help),
        Row(cellType: .app)
    ]
    // 高さ
    let cellHeight = AppConst.FRONT_LAYER_TABLE_VIEW_CELL_HEIGHT
    // 数
    var cellCount: Int {
        return rows.count
    }
    // 詳細ビューのマージン
    let overViewMargin = AppConst.FRONT_LAYER_OVER_VIEW_MARGIN
    
    /// セル情報取得
    func getRow(indexPath: IndexPath) -> Row {
        return rows[indexPath.row]
    }
    
    /// 履歴情報永続化
    func storeHistory() {
        CommonHistoryDataModel.s.store()
        PageHistoryDataModel.s.store()
    }
}
