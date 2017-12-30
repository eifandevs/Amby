//
//  OptionMenuHelpTableViewModel.swift
//  Qas
//
//  Created by temma on 2017/12/31.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

class OptionMenuHelpTableViewModel {
    private let objectKeySubTitle = AppConst.KEY_NOTIFICATION_SUBTITLE
    private let objectKeyMessage = AppConst.KEY_NOTIFICATION_MESSAGE
    
    // セル情報
    struct Row {
        let title: String
        let subTitle: String
        let message: String
    }
    
    // セル
    let rows = [
        Row(title: MessageConst.HELP_HISTORY_SAVE_TITLE, subTitle: MessageConst.HELP_HISTORY_SAVE_SUBTITLE, message: MessageConst.HELP_HISTORY_SAVE_MESSAGE),
        Row(title: MessageConst.HELP_SEARCH_CLOSE_TITLE, subTitle: MessageConst.HELP_SEARCH_CLOSE_SUBTITLE, message: MessageConst.HELP_SEARCH_CLOSE_MESSAGE),
        Row(title: MessageConst.HELP_FORM_TITLE, subTitle: MessageConst.HELP_FORM_SUB_TITLE, message: MessageConst.HELP_FORM_MESSAGE),
        Row(title: MessageConst.HELP_AUTO_SCROLL_TITLE, subTitle: MessageConst.HELP_AUTO_SCROLL_SUBTITLE, message: MessageConst.HELP_AUTO_SCROLL_MESSAGE),
        Row(title: MessageConst.HELP_TAB_TRANSITION_TITLE, subTitle: MessageConst.HELP_TAB_TRANSITION_SUBTITLE, message: MessageConst.HELP_TAB_TRANSITION_MESSAGE),
        Row(title: MessageConst.HELP_TAB_DELETE_TITLE, subTitle: MessageConst.HELP_TAB_DELETE_SUBTITLE, message: MessageConst.HELP_TAB_DELETE_MESSAGE),
        Row(title: MessageConst.HELP_DATA_DELETE_TITLE, subTitle: MessageConst.HELP_DATA_DELETE_SUBTITLE, message: MessageConst.HELP_DATA_DELETE_MESSAGE),

    ]
    
    // 高さ
    let cellHeight = AppConst.FRONT_LAYER_TABLE_VIEW_CELL_HEIGHT
    // 数
    var cellCount: Int {
        return rows.count
    }
    
    /// セル情報取得
    func getRow(indexPath: IndexPath) -> Row {
        return rows[indexPath.row]
    }
    
    /// ヘルプ表示
    func executeOperationDataModel(indexPath: IndexPath) {
        let row = getRow(indexPath: indexPath)
        OperationDataModel.s.executeOperation(operation: .help, object: [
            self.objectKeySubTitle: row.subTitle,
            self.objectKeyMessage : row.message
        ])
    }
}
