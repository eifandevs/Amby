//
//  OptionMenuSettingTableViewModel.swift
//  Qas
//
//  Created by temma on 2017/12/24.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

class OptionMenuSettingTableViewModel {
    /// セル情報
    struct Section {
        let title: String
        var rows: [Row]
        
        struct Row {
            let cellType: CellType
            let title: String?
        }
    }
    
    /// セルタイプ
    enum CellType {
        case autoScroll
        case historyDelete
    }
    
    let cellHeight = AppConst.FRONT_LAYER_TABLE_VIEW_CELL_HEIGHT
    // セクション数
    var sectionCount: Int {
        return sections.count
    }
    // セクションの高さ
    let sectionHeight = AppConst.FRONT_LAYER_TABLE_VIEW_SECTION_HEIGHT
    
    // セル情報
    var sections: [Section] = [
        Section(title: AppConst.SETTING_SECTION_AUTO_SCROLL, rows: [
            Section.Row(cellType: .autoScroll, title: nil)
        ]),
        Section(title: AppConst.SETTING_SECTION_DELETE, rows: [
            Section.Row(cellType: .historyDelete, title: AppConst.SETTING_TITLE_COMMON_HISTORY),
            Section.Row(cellType: .historyDelete, title: AppConst.SETTING_TITLE_BOOK_MARK),
            Section.Row(cellType: .historyDelete, title: AppConst.SETTING_TITLE_FORM_DATA),
            Section.Row(cellType: .historyDelete, title: AppConst.SETTING_TITLE_SEARCH_HISTORY),
            Section.Row(cellType: .historyDelete, title: AppConst.SETTING_TITLE_COOKIES),
            Section.Row(cellType: .historyDelete, title: AppConst.SETTING_TITLE_SITE_DATA),
            Section.Row(cellType: .historyDelete, title: AppConst.SETTING_TITLE_ALL)
        ])
    ]
    // セクションフォントサイズ
    let sectionFontSize = 12.f
    
    /// セル数
    func cellCount(section: Int) -> Int {
        return sections[section].rows.count
    }
    
    /// セル情報取得
    func getRow(indexPath: IndexPath) -> Section.Row {
        return sections[indexPath.section].rows[indexPath.row]
    }
    
    /// セクション情報取得
    func getSection(section: Int) -> Section {
        return sections[section]
    }
}
