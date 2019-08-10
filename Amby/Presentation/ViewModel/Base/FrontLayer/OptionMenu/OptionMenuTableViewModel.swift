//
//  OptionMenuTableViewModel.swift
//  Amby
//
//  Created by temma on 2017/12/16.
//  Copyright © 2017年 eifandevs. All rights reserved.
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
        case tabGroup
        case trend
        case history
        case form
        case favorite
        case memo
        case setting
        case help
        case cooperation
        case sync
        case analysisHtml
        case app

        var imageName: String {
            switch self {
            case .tabGroup: return R.image.optionmenuHistory.name
            case .trend: return R.image.optionmenuHistory.name
            case .history: return R.image.optionmenuHistory.name
            case .form: return R.image.optionmenuForm.name
            case .favorite: return R.image.optionmenuFavorite.name
            case .memo: return R.image.optionmenuMemo.name
            case .setting: return R.image.optionmenuSetting.name
            case .help: return R.image.optionmenuHelp.name
            case .cooperation: return R.image.optionmenuApp.name
            case .sync: return R.image.optionmenuApp.name
            case .analysisHtml: return R.image.optionmenuApp.name
            case .app: return R.image.optionmenuApp.name
            }
        }

        var title: String {
            switch self {
            case .tabGroup: return AppConst.OPTION_MENU.TAB_GROUP
            case .trend: return AppConst.OPTION_MENU.TREND
            case .history: return AppConst.OPTION_MENU.HISTORY
            case .form: return AppConst.OPTION_MENU.FORM
            case .favorite: return AppConst.OPTION_MENU.BOOKMARK
            case .memo: return AppConst.OPTION_MENU.MEMO
            case .setting: return AppConst.OPTION_MENU.SETTING
            case .help: return AppConst.OPTION_MENU.HELP
            case .cooperation: return AppConst.OPTION_MENU.COORERATION
            case .sync: return AppConst.OPTION_MENU.SYNC
            case .analysisHtml: return AppConst.OPTION_MENU.ANALYTICS
            case .app: return AppConst.OPTION_MENU.APP_INFORMATION
            }
        }
    }

    // セル
    let rows = [
        Row(cellType: .tabGroup),
        Row(cellType: .history),
        Row(cellType: .form),
        Row(cellType: .favorite),
        Row(cellType: .memo),
        Row(cellType: .trend),
        Row(cellType: .setting),
        Row(cellType: .help),
        Row(cellType: .cooperation),
        Row(cellType: .analysisHtml),
        Row(cellType: .sync),
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
        TrendHandlerUseCase.s.load()
    }

    /// 同期画面表示
    func openSync() {
        SyncHandlerUseCase.s.open()
    }

    /// html表示
    func analysisHtml() {
        HtmlAnalysisHandlerUseCase.s.analytics()
    }
}
