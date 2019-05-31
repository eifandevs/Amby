//
//  OptionMenuSettingTableViewModel.swift
//  Amby
//
//  Created by temma on 2017/12/24.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import Model
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
        case passcode
        case autoScroll
        case windowConfirm
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
            case .passcode: return AppConst.OPTION_MENU.PASSCODE
            case .menu: return AppConst.OPTION_MENU.MENU
            case .commonHistory: return AppConst.OPTION_MENU.HISTORY
            case .form: return AppConst.SETTING.TITLE_FORM_DATA
            case .bookMark: return AppConst.SETTING.TITLE_BOOK_MARK
            case .searchHistory: return AppConst.SETTING.TITLE_SEARCH_HISTORY
            case .cookies: return AppConst.SETTING.TITLE_COOKIES
            case .siteData: return AppConst.SETTING.TITLE_SITE_DATA
            case .all: return AppConst.SETTING.TITLE_ALL
            default: return ""
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
        Section(title: AppConst.SETTING.SECTION_SETTING, rows: [
            Section.Row(cellType: .passcode),
            Section.Row(cellType: .menu),
            Section.Row(cellType: .autoScroll),
            Section.Row(cellType: .windowConfirm)
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

    /// パスコード設定
    func openPasscodeSetting() {
        PasscodeUseCase.s.open()
    }

    /// メニュ-順序
    func openMenuOrder() {
        MenuOrderUseCase.s.open()
    }

    /// 閲覧履歴削除
    func deleteHistory() {
        NotificationService.presentAlert(title: MessageConst.ALERT.DELETE_TITLE, message: MessageConst.ALERT.DELETE_COMMON_HISTORY, completion: {
            HistoryUseCase.s.delete()
        })
    }

    /// お気に入り削除
    func deleteFavorite() {
        NotificationService.presentAlert(title: MessageConst.ALERT.DELETE_TITLE, message: MessageConst.ALERT.DELETE_BOOK_MARK, completion: {
            FavoriteUseCase.s.delete()
        })
    }

    /// フォーム削除
    func deleteForm() {
        NotificationService.presentAlert(title: MessageConst.ALERT.DELETE_TITLE, message: MessageConst.ALERT.DELETE_FORM, completion: {
            FormUseCase.s.delete()
        })
    }

    /// 検索履歴削除
    func deleteSearchHistory() {
        NotificationService.presentAlert(title: MessageConst.ALERT.DELETE_TITLE, message: MessageConst.ALERT.DELETE_SEARCH_HISTORY, completion: {
            SearchUseCase.s.delete()
        })
    }

    /// クッキー削除
    func deleteCookies() {
        NotificationService.presentAlert(title: MessageConst.ALERT.DELETE_TITLE, message: MessageConst.ALERT.DELETE_COOKIES, completion: {
            WebCacheUseCase.s.deleteCookies()
        })
    }

    /// キャッシュ削除
    func deleteCaches() {
        NotificationService.presentAlert(title: MessageConst.ALERT.DELETE_TITLE, message: MessageConst.ALERT.DELETE_SITE_DATA, completion: {
            WebCacheUseCase.s.deleteCaches()
        })
    }

    /// 全て削除
    func deleteAll() {
        NotificationService.presentAlert(title: MessageConst.ALERT.DELETE_TITLE, message: MessageConst.ALERT.DELETE_ALL, completion: {
            HistoryUseCase.s.delete()
            SearchUseCase.s.delete()
            FavoriteUseCase.s.delete()
            FormUseCase.s.delete()
            WebCacheUseCase.s.deleteCookies()
            WebCacheUseCase.s.deleteCaches()
            ThumbnailUseCase.s.delete()
            TabUseCase.s.delete()
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.initialize()
            }
        })
    }
}
