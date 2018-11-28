//
//  OptionMenuHelpTableViewModel.swift
//  Qas
//
//  Created by temma on 2017/12/31.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import Model

final class OptionMenuHelpTableViewModel {
    private let objectKeySubTitle = AppConst.KEY.NOTIFICATION_SUBTITLE
    private let objectKeyMessage = AppConst.KEY.NOTIFICATION_MESSAGE

    // セル情報
    struct Row {
        let title: String
        let subTitle: String
        let message: String
    }

    // セル
    let rows = [
        Row(title: MessageConst.HELP.HISTORY_SAVE_TITLE, subTitle: MessageConst.HELP.HISTORY_SAVE_SUBTITLE, message: MessageConst.HELP.HISTORY_SAVE_MESSAGE),
        Row(title: MessageConst.HELP.SEARCH_CLOSE_TITLE, subTitle: MessageConst.HELP.SEARCH_CLOSE_SUBTITLE, message: MessageConst.HELP.SEARCH_CLOSE_MESSAGE),
        Row(title: MessageConst.HELP.FORM_TITLE, subTitle: MessageConst.HELP.FORM_SUB_TITLE, message: MessageConst.HELP.FORM_MESSAGE),
        Row(title: MessageConst.HELP.AUTO_SCROLL_TITLE, subTitle: MessageConst.HELP.AUTO_SCROLL_SUBTITLE, message: MessageConst.HELP.AUTO_SCROLL_MESSAGE),
        Row(title: MessageConst.HELP.TAB_TRANSITION_TITLE, subTitle: MessageConst.HELP.TAB_TRANSITION_SUBTITLE, message: MessageConst.HELP.TAB_TRANSITION_MESSAGE),
        Row(title: MessageConst.HELP.TAB_DELETE_TITLE, subTitle: MessageConst.HELP.TAB_DELETE_SUBTITLE, message: MessageConst.HELP.TAB_DELETE_MESSAGE),
        Row(title: MessageConst.HELP.DATA_DELETE_TITLE, subTitle: MessageConst.HELP.DATA_DELETE_SUBTITLE, message: MessageConst.HELP.DATA_DELETE_MESSAGE),
    ]

    // 高さ
    let cellHeight = AppConst.FRONT_LAYER.TABLE_VIEW_CELL_HEIGHT
    // 数
    var cellCount: Int {
        return rows.count
    }

    /// セル情報取得
    func getRow(indexPath: IndexPath) -> Row {
        return rows[indexPath.row]
    }

    /// ヘルプ表示
    func openHelpScreen(title: String, message: String) {
        HelpUseCase.s.open(title: title, message: message)
    }
}
