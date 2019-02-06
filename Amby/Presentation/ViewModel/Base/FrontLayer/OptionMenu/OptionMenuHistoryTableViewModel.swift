//
//  OptionMenuHistoryTableViewModel.swift
//  Qas
//
//  Created by temma on 2017/12/17.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import Model
import RxCocoa
import RxSwift

enum OptionMenuHistoryTableViewModelAction {
    case gotData
}

final class OptionMenuHistoryTableViewModel {
    /// アクション通知用RX
    let rx_action = PublishSubject<OptionMenuHistoryTableViewModelAction>()
    /// セルの高さ
    let cellHeight = AppConst.FRONT_LAYER.TABLE_VIEW_CELL_HEIGHT
    /// セクション数
    var sectionCount: Int {
        return sections.count
    }

    /// セクションの高さ
    let sectionHeight = AppConst.FRONT_LAYER.TABLE_VIEW_SECTION_HEIGHT
    /// セル情報
    var sections: [Section] = []
    /// 保持データリスト
    private var readFiles = HistoryUseCase.s.getList()
    /// ファイル読み込みインターバル
    private let readInterval = 6
    /// セクションフォントサイズ
    let sectionFontSize = 12.f

    /// セル数
    func cellCount(section: Int) -> Int {
        return sections[section].rows.count
    }

    /// セル情報取得
    func getRow(indexPath: IndexPath) -> Section.Row {
        return sections[indexPath.section].rows[indexPath.row]
    }

    /// セル削除
    /// セルの有無を返却する
    func removeRow(indexPath: IndexPath) -> Bool {
        let row = getRow(indexPath: indexPath)

        sections[indexPath.section].rows.remove(at: indexPath.row)
        // モデルから削除
        HistoryUseCase.s.delete(historyIds: [getSection(section: indexPath.section).dateString: [row.data._id]])

        return sections[indexPath.section].rows.count > 0
    }

    /// セクション削除
    func removeSection(section: Int) {
        sections.remove(at: section)
    }

    /// セクション情報取得
    func getSection(section: Int) -> Section {
        return sections[section]
    }

    /// モデルデータ(閲覧履歴)取得
    func getModelData() {
        if readFiles.count > 0 {
            log.debug("common history additional loaded.")
            let latestFiles = readFiles.prefix(readInterval)
            readFiles = Array(readFiles.dropFirst(readInterval))
            latestFiles.forEach({ (dateString: String) in
                let rows = HistoryUseCase.s.select(dateString: dateString).map({ Section.Row(data: $0) })
                if rows.count > 0 {
                    sections.append(Section(dateString: dateString, rows: rows))
                }
            })
            rx_action.onNext(.gotData)
        }
    }

    /// ロードリクエスト
    func loadRequest(url: String) {
        HistoryUseCase.s.load(url: url)
    }

    /// セル情報
    struct Section {
        let dateString: String
        var rows: [Row]

        struct Row {
            let data: CommonHistory
        }
    }
}
