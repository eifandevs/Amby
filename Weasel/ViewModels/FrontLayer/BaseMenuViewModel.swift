//
//  BaseMenuViewModel.swift
//  Weasel
//
//  Created by User on 2017/06/13.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class BaseMenuViewModel: OptionMenuTableViewModel {
    override init() {
        super.init()
    }
    
    override func setup() {
        menuItems = [
            [
                OptionMenuItem(title: "新しいタブ", image: UIImage(named: "historyforward_webview"), action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    NotificationCenter.default.post(name: .baseViewModelWillAddWebView, object: nil)
                    return nil
                }),
                OptionMenuItem(title: "新しいタブ(URLコピー)", image: UIImage(named: "historyforward_webview"), action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    NotificationCenter.default.post(name: .baseViewModelWillCopyWebView, object: nil)
                    return nil
                }),
                OptionMenuItem(title: "履歴", image: UIImage(named: "historyforward_webview"), action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in return HistoryMenuViewModel()
                }),
                OptionMenuItem(title: "フォーム", image: UIImage(named: "historyforward_webview"), action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in return FormMenuViewModel()
                }),
                OptionMenuItem(title: "ブックマーク", image: UIImage(named: "historyforward_webview"), action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in return FavoriteMenuViewModel()
                }),
                OptionMenuItem(title: "問題の報告", image: UIImage(named: "historyforward_webview"), action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in return SettingMenuViewModel()
                }),
                OptionMenuItem(title: "設定", image: UIImage(named: "historyforward_webview"), action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in return SettingMenuViewModel()
                }),
                OptionMenuItem(title: "ヘルプ", image: UIImage(named: "historyforward_webview")),
                OptionMenuItem(title: "初期化", image: UIImage(named: "historyforward_webview"), action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in return SettingMenuViewModel()
                }),
            ]
        ]
    }
}
