//
//  UserOperation+Extend.swift
//  Qass
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
}
