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
            [
                OptionMenuItem(titleText: "新しいタブ", urlText: nil, thumbnailImage: nil),
                OptionMenuItem(titleText: "新しいタブ(URLコピー)", urlText: nil, thumbnailImage: nil),
                OptionMenuItem(titleText: "履歴", urlText: nil, thumbnailImage: nil),
                OptionMenuItem(titleText: "フォーム", urlText: nil, thumbnailImage: nil),
                OptionMenuItem(titleText: "お気に入り", urlText: nil, thumbnailImage: nil),
                OptionMenuItem(titleText: "キャッシュ設定", urlText: nil, thumbnailImage: nil),
                OptionMenuItem(titleText: "設定", urlText: nil, thumbnailImage: nil),
                OptionMenuItem(titleText: "ヘルプ", urlText: nil, thumbnailImage: nil)
            ]
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
