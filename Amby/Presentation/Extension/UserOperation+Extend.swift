//
//  UserOperation+Extend.swift
//  Amby
//
//  Created by tenma on 2018/11/18.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import Model

extension UserOperation {
    func title() -> String {
        switch self {
        case .menu:
            return "メニュー"
        case .add:
            return "タブの追加"
        case .close:
            return "タブの削除"
        case .closeAll:
            return "全てのタブを削除"
        case .copy:
            return "タブのコピー"
        case .autoScroll:
            return "自動スクロール"
        case .grep:
            return "タブ内検索"
        case .form:
            return "フォーム内容の記録"
        case .favorite:
            return "お気に入り追加"
        case .urlCopy:
            return "URLのコピー"
        case .search:
            return "Web検索"
        case .scrollUp:
            return "スクロールトップ"
        case .historyBack:
            return "前ページに戻る"
        case .historyForward:
            return "次ページに進む"
        case .tabGroup:
            return "タブグループ"
        }
    }

    func imageColor() -> UIColor {
        return UIColor.darkGray
    }

    func image() -> UIImage {
        switch self {
        case .menu:
            return R.image.circlemenuMenu()!
        case .close:
            return R.image.circlemenuClose()!
        case .closeAll:
            return R.image.circlemenuCloseAll()!
        case .historyBack:
            return R.image.circlemenuHistoryback()!
        case .copy:
            return R.image.circlemenuCopy()!
        case .search:
            return R.image.circlemenuSearch()!
        case .grep:
            return R.image.circlemenuGrep()!
        case .add:
            return R.image.circlemenuAdd()!
        case .scrollUp:
            return R.image.circlemenuScrollup()!
        case .autoScroll:
            return R.image.circlemenuAutoscroll()!
        case .historyForward:
            return R.image.circlemenuHistoryforward()!
        case .form:
            return R.image.circlemenuForm()!
        case .favorite:
            return R.image.circlemenuFavorite()!
        case .urlCopy:
            // TODO: URLコピーの画像
            return R.image.circlemenuFavorite()!
        case .tabGroup:
            // TODO: タブグループの画像
            return R.image.circlemenuFavorite()!
        }
    }

    func accesibilityIdentify() -> String {
        switch self {
        case .menu:
            return R.image.circlemenuMenu.name
        case .close:
            return R.image.circlemenuClose.name
        case .closeAll:
            return R.image.circlemenuCloseAll.name
        case .historyBack:
            return R.image.circlemenuHistoryback.name
        case .copy:
            return R.image.circlemenuCopy.name
        case .search:
            return R.image.circlemenuSearch.name
        case .grep:
            return R.image.circlemenuGrep.name
        case .add:
            return R.image.circlemenuAdd.name
        case .scrollUp:
            return R.image.circlemenuScrollup.name
        case .autoScroll:
            return R.image.circlemenuAutoscroll.name
        case .historyForward:
            return R.image.circlemenuHistoryforward.name
        case .form:
            return R.image.circlemenuForm.name
        case .favorite:
            return R.image.circlemenuFavorite.name
        case .urlCopy:
            // TODO: URLコピーの画像
            return R.image.circlemenuFavorite.name
        case .tabGroup:
            // TODO: タブグループの画像
            return R.image.circlemenuFavorite.name
        }
    }
}
