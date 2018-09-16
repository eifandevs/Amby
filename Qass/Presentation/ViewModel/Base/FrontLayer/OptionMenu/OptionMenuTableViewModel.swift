//
//  OptionMenuTableViewModel.swift
//  Qas
//
//  Created by temma on 2017/12/16.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import Model

final class OptionMenuTableViewModel {
    // セル情報
    struct Row {
        let cellType: CellType
    }

    /// セルタイプ
    enum CellType {
        case trend
        case history
        case form
        case favorite
        case setting
        case help
        case app

        var imageName: String {
            switch self {
            case .trend: return R.image.optionmenuHistory.name
            case .history: return R.image.optionmenuHistory.name
            case .form: return R.image.optionmenuForm.name
            case .favorite: return R.image.optionmenuFavorite.name
            case .setting: return R.image.optionmenuSetting.name
            case .help: return R.image.optionmenuHelp.name
            case .app: return R.image.optionmenuApp.name
            }
        }

        var title: String {
            switch self {
            case .trend: return AppConst.OPTION_MENU.TREND
            case .history: return AppConst.OPTION_MENU.HISTORY
            case .form: return AppConst.OPTION_MENU.FORM
            case .favorite: return AppConst.OPTION_MENU.BOOKMARK
            case .setting: return AppConst.OPTION_MENU.SETTING
            case .help: return AppConst.OPTION_MENU.HELP
            case .app: return AppConst.OPTION_MENU.APP_INFORMATION
            }
        }
    }

    // セル
    let rows = [
        Row(cellType: .history),
        Row(cellType: .form),
        Row(cellType: .favorite),
        Row(cellType: .trend),
        Row(cellType: .setting),
        Row(cellType: .help),
        Row(cellType: .app)
    ]
    // 高さ
    let cellHeight = AppConst.FRONT_LAYER.TABLE_VIEW_CELL_HEIGHT
    // 数
    var cellCount: Int {
        return rows.count
    }

    /// スワイプ方向
    var swipeDirection: EdgeSwipeDirection?

    /// セル情報取得
    func getRow(indexPath: IndexPath) -> Row {
        return rows[indexPath.row]
    }

    /// 詳細ビューのマージン取得
    func getOverViewMargin() -> CGPoint {
        if let swipeDirection = swipeDirection {
            if swipeDirection == .left {
                return AppConst.FRONT_LAYER.OVER_VIEW_MARGIN
            } else {
                return CGPoint(x: -AppConst.FRONT_LAYER.OVER_VIEW_MARGIN.x, y: AppConst.FRONT_LAYER.OVER_VIEW_MARGIN.y)
            }
        } else {
            return AppConst.FRONT_LAYER.OVER_VIEW_MARGIN
        }
    }

    /// トレンド表示
    func loadTrend() {
        TrendUseCase.s.load()
    }

    /// 履歴情報永続化
    func storeHistory() {
        HistoryUseCase.s.store()
        TabUseCase.s.store()
    }
}
