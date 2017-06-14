//
//  BaseMenuViewModel.swift
//  Weasel
//
//  Created by User on 2017/06/13.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

class BaseMenuViewModel: OptionMenuTableViewModel {
    override init() {
        super.init()
        menuItems = [
            "新しいタブ",
            "新しいタブ(URLコピー)",
            "履歴",
            "フォーム",
            "お気に入り",
            "キャッシュ設定",
            "設定",
            "ヘルプ"
        ]
        actionItems = [
            { () -> OptionMenuTableViewModel? in
                NotificationCenter.default.post(name: .baseViewModelWillAddWebView, object: nil)
                return nil
            },
            { () -> OptionMenuTableViewModel? in
                NotificationCenter.default.post(name: .baseViewModelWillCopyWebView, object: nil)
                return nil
            },
            { () -> OptionMenuTableViewModel? in return HistoryMenuViewModel() },
            { () -> OptionMenuTableViewModel? in return SettingMenuViewModel() },
            { () -> OptionMenuTableViewModel? in return SettingMenuViewModel() },
            { () -> OptionMenuTableViewModel? in return SettingMenuViewModel() },
            { () -> OptionMenuTableViewModel? in return SettingMenuViewModel() },
            { () -> OptionMenuTableViewModel? in return SettingMenuViewModel() }
        ]
    }
}
