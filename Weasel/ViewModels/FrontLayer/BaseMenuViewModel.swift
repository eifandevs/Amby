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
    }
    
    override func setup() {
        menuItems = [
            [
                OptionMenuItem(titleText: "新しいタブ", urlText: nil, image: nil),
                OptionMenuItem(titleText: "新しいタブ(URLコピー)", urlText: nil, image: nil),
                OptionMenuItem(titleText: "履歴", urlText: nil, image: nil),
                OptionMenuItem(titleText: "フォーム", urlText: nil, image: nil),
                OptionMenuItem(titleText: "お気に入り", urlText: nil, image: nil),
                OptionMenuItem(titleText: "キャッシュ設定", urlText: nil, image: nil),
                OptionMenuItem(titleText: "設定", urlText: nil, image: nil),
                OptionMenuItem(titleText: "ヘルプ", urlText: nil, image: nil)
            ]
        ]
        actionItems = [
            [
                { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    NotificationCenter.default.post(name: .baseViewModelWillAddWebView, object: nil)
                    return nil
                },
                { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    NotificationCenter.default.post(name: .baseViewModelWillCopyWebView, object: nil)
                    return nil
                },
                { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in return HistoryMenuViewModel() },
                { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in return FormMenuViewModel() },
                { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in return FavoriteMenuViewModel() },
                { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in return SettingMenuViewModel() },
                { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in return SettingMenuViewModel() },
                { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in return SettingMenuViewModel() }
            ]
        ]
    }
}
