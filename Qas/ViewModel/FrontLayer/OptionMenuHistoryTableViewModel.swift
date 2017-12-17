//
//  OptionMenuHistoryTableViewModel.swift
//  Qas
//
//  Created by temma on 2017/12/17.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

protocol OptionMenuHistoryTableViewModelDelegate: class {
    func optionMenuHistoryTableViewModelDidGetDataSuccessfull()
}

class OptionMenuHistoryTableViewModel {
    let cellHeight = AppConst.FRONT_LAYER_TABLE_VIEW_CELL_HEIGHT
    var cellCount: Int {
        return rows.count
    }
    // セル情報
    var rows: [Row] = []
    // 通知
    var delegate: OptionMenuHistoryTableViewModelDelegate?
    // 保持データリスト
    private var readFiles = CommonHistoryDataModel.s.getList()
    // ファイル読み込みインターバル
    private let readInterval = 6

    /// セル情報取得
    func getRow(indexPath: IndexPath) -> Row {
        return rows[indexPath.row]
    }
    
    /// モデルデータ(閲覧履歴)取得
    func getModelData() {
        if readFiles.count > 0 {
            let latestFiles = readFiles.prefix(readInterval)
            self.readFiles = Array(readFiles.dropFirst(readInterval))
            latestFiles.forEach({ (dateString: String) in
                let commonHistory = CommonHistoryDataModel.s.select(dateString: dateString)
                if commonHistory.count > 0 {
                    rows.append(Row(dateString: dateString, histories: commonHistory))
                }
            })
        }
        delegate?.optionMenuHistoryTableViewModelDidGetDataSuccessfull()
    }

    /// セル情報
    struct Row {
        let dateString: String
        let histories: [CommonHistory]
    }
}
