//
//  OptionMenuSettingTableViewModel.swift
//  Amby
//
//  Created by temma on 2017/12/24.
//  Copyright © 2017年 eifandevs. All rights reserved.
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
        case signIn
        case signOut
        case accountDelete

        var title: String {
            switch self {
            case .menu: return AppConst.OPTION_MENU.MENU
            case .commonHistory: return AppConst.OPTION_MENU.HISTORY
            case .form: return AppConst.SETTING.TITLE_FORM_DATA
            case .bookMark: return AppConst.SETTING.TITLE_BOOK_MARK
            case .searchHistory: return AppConst.SETTING.TITLE_SEARCH_HISTORY
            case .cookies: return AppConst.SETTING.TITLE_COOKIES
            case .siteData: return AppConst.SETTING.TITLE_SITE_DATA
            case .all: return AppConst.SETTING.TITLE_ALL
            case .signIn: return AppConst.SETTING.SIGNIN
            case .signOut: return AppConst.SETTING.SIGNOUT
            case .accountDelete: return AppConst.SETTING.ACCOUNT_DELETE
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
            Section.Row(cellType: .menu),
            Section.Row(cellType: .autoScroll),
            Section.Row(cellType: .windowConfirm)
        ]),
        Section(title: AppConst.SETTING.SECTION_SYNC, rows: [
            Section.Row(cellType: .signIn),
            Section.Row(cellType: .signOut),
            Section.Row(cellType: .accountDelete)
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

    /// ログイン中
    var isLoggedIn: Bool {
        return FBLoginService().isLoggedIn
    }

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
        LocalAuthenticationHandlerUseCase.s.open()
    }

    /// メニュ-順序
    func openMenuOrder() {
        MenuOrderHandlerUseCase.s.open()
    }

    /// 閲覧履歴削除
    func deleteHistory() {
        NotificationService.presentAlert(title: MessageConst.ALERT.DELETE_TITLE, message: MessageConst.ALERT.DELETE_COMMON_HISTORY, completion: {
            DeleteHistoryUseCase().exe()
        })
    }

    /// お気に入り削除
    func deleteFavorite() {
        NotificationService.presentAlert(title: MessageConst.ALERT.DELETE_TITLE, message: MessageConst.ALERT.DELETE_BOOK_MARK, completion: {
            DeleteFavoriteUseCase().exe()
        })
    }

    /// フォーム削除
    func deleteForm() {
        NotificationService.presentAlert(title: MessageConst.ALERT.DELETE_TITLE, message: MessageConst.ALERT.DELETE_FORM, completion: {
            DeleteFormUseCase().exe()
        })
    }

    /// 検索履歴削除
    func deleteSearchHistory() {
        NotificationService.presentAlert(title: MessageConst.ALERT.DELETE_TITLE, message: MessageConst.ALERT.DELETE_SEARCH_HISTORY, completion: {
            DeleteSearchUseCase().exe()
        })
    }

    /// クッキー削除
    func deleteCookies() {
        NotificationService.presentAlert(title: MessageConst.ALERT.DELETE_TITLE, message: MessageConst.ALERT.DELETE_COOKIES, completion: {
            WebCacheHandlerUseCase.s.deleteCookies()
        })
    }

    /// キャッシュ削除
    func deleteCaches() {
        NotificationService.presentAlert(title: MessageConst.ALERT.DELETE_TITLE, message: MessageConst.ALERT.DELETE_SITE_DATA, completion: {
            WebCacheHandlerUseCase.s.deleteCaches()
        })
    }

    /// 全て削除
    func deleteAll() {
        NotificationService.presentAlert(title: MessageConst.ALERT.DELETE_TITLE, message: MessageConst.ALERT.DELETE_ALL, completion: {
            DeleteHistoryUseCase().exe()
            DeleteSearchUseCase().exe()
            DeleteFavoriteUseCase().exe()
            DeleteFormUseCase().exe()
            WebCacheHandlerUseCase.s.deleteCookies()
            WebCacheHandlerUseCase.s.deleteCaches()
            DeleteThumbnailUseCase().exe()
            DeleteTabUseCase().exe()
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.initialize()
            }
        })
    }

    /// ログイン
    func signIn() {
        if isLoggedIn {
            NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.ALREADY_LOGGED_IN_ERROR, isSuccess: false)
            return
        }
        SyncHandlerUseCase.s.open()
    }

    /// ログアウト
    func signOut() {
        if !isLoggedIn {
            NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.NOT_LOGIN_IN_ERROR, isSuccess: false)
            return
        }
        FBLoginService().signOut()
    }

    /// アカウント削除
    func deleteAccount() {
        let loginService = FBLoginService()
        loginService.deleteAccount()
    }
}
