//
//  OptionMenuSettingTableViewModel.swift
//  Qas
//
//  Created by temma on 2017/12/24.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

final class OptionMenuSettingTableViewModel {
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
        case menu
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
            case .menu: return AppConst.OPTION_MENU.MENU
            case .commonHistory: return AppConst.OPTION_MENU.HISTORY
            case .form: return AppConst.SETTING.TITLE_FORM_DATA
            case .bookMark: return AppConst.SETTING.TITLE_BOOK_MARK
            case .searchHistory: return AppConst.SETTING.TITLE_SEARCH_HISTORY
            case .cookies: return AppConst.SETTING.TITLE_COOKIES
            case .siteData: return AppConst.SETTING.TITLE_SITE_DATA
            case .all: return AppConst.SETTING.TITLE_ALL
            }
        }
    }

    let cellHeight = AppConst.FRONT_LAYER.TABLE_VIEW_CELL_HEIGHT
    // セクション数
    var sectionCount: Int {
        return sections.count
    }

    // セクションの高さ
    let sectionHeight = AppConst.FRONT_LAYER.TABLE_VIEW_SECTION_HEIGHT

    // セル情報
    var sections: [Section] = [
        Section(title: AppConst.SETTING.SECTION_AUTO_SCROLL, rows: [
            Section.Row(cellType: .autoScroll)
        ]),
        Section(title: AppConst.SETTING.SECTION_MENU, rows: [
            Section.Row(cellType: .menu)
        ]),
        Section(title: AppConst.SETTING.SECTION_DELETE, rows: [
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

    /// 閲覧履歴削除
    func deleteHistory() {
        NotificationManager.presentAlert(title: MessageConst.ALERT.DELETE_TITLE, message: MessageConst.ALERT.DELETE_COMMON_HISTORY, completion: {
            HistoryUseCase.s.delete()
        }
        )
    }

    /// お気に入り削除
    func deleteFavorite() {
        NotificationManager.presentAlert(title: MessageConst.ALERT.DELETE_TITLE, message: MessageConst.ALERT.DELETE_BOOK_MARK, completion: {
            FavoriteUseCase.s.delete()
        }
        )
    }

    /// フォーム削除
    func deleteForm() {
        NotificationManager.presentAlert(title: MessageConst.ALERT.DELETE_TITLE, message: MessageConst.ALERT.DELETE_FORM, completion: {
            FormUseCase.s.delete()
        }
        )
    }

    /// 検索履歴削除
    func deleteSearchHistory() {
        NotificationManager.presentAlert(title: MessageConst.ALERT.DELETE_TITLE, message: MessageConst.ALERT.DELETE_SEARCH_HISTORY, completion: {
            SearchUseCase.s.delete()
        }
        )
    }

    /// クッキー削除
    func deleteCookies() {
        NotificationManager.presentAlert(title: MessageConst.ALERT.DELETE_TITLE, message: MessageConst.ALERT.DELETE_COOKIES, completion: {
            CacheUseCase.s.deleteCookies()
        }
        )
    }

    /// キャッシュ削除
    func deleteCaches() {
        NotificationManager.presentAlert(title: MessageConst.ALERT.DELETE_TITLE, message: MessageConst.ALERT.DELETE_SITE_DATA, completion: {
            CacheUseCase.s.deleteCaches()
        }
        )
    }

    /// 全て削除
    func deleteAll() {
        NotificationManager.presentAlert(title: MessageConst.ALERT.DELETE_TITLE, message: MessageConst.ALERT.DELETE_ALL, completion: {
            CommonHistoryDataModel.s.delete()
            SearchHistoryDataModel.s.delete()
            FavoriteDataModel.s.delete(notify: false)
            FormDataModel.s.delete()
            CacheHelper.deleteCookies()
            CacheHelper.deleteCaches()
            ThumbnailDataModel.s.delete()
            PageHistoryDataModel.s.delete()
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.initialize()
            }
        })
    }
}
