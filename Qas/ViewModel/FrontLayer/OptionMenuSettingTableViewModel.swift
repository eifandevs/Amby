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
        }
    }
    
    /// セルタイプ
    enum CellType {
        case autoScroll
        case commonHistory
        case bookMark
        case form
        case searchHistory
        case cookies
        case siteData
        case all
        
        var title: String {
            switch self {
            case .autoScroll: return ""
            case .commonHistory: return AppConst.OPTION_MENU_HISTORY
            case .form: return AppConst.SETTING_TITLE_FORM_DATA
            case .bookMark: return AppConst.SETTING_TITLE_BOOK_MARK
            case .searchHistory: return AppConst.SETTING_TITLE_SEARCH_HISTORY
            case .cookies: return AppConst.SETTING_TITLE_COOKIES
            case .siteData: return AppConst.SETTING_TITLE_SITE_DATA
            case .all: return AppConst.SETTING_TITLE_ALL
            }
        }
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
            Section.Row(cellType: .autoScroll)
        ]),
        Section(title: AppConst.SETTING_SECTION_DELETE, rows: [
            Section.Row(cellType: .commonHistory),
            Section.Row(cellType: .form),
            Section.Row(cellType: .bookMark),
            Section.Row(cellType: .searchHistory),
            Section.Row(cellType: .cookies),
            Section.Row(cellType: .siteData),
            Section.Row(cellType: .all)
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
