//
//  BaseMenuViewModel.swift
//  Qas
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
                OptionMenuItem(title: "新しいタブ", image: UIImage(named: "option_menu_add"), action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    PageHistoryDataModel.s.insert(url: nil)
                    return nil
                }),
                OptionMenuItem(title: "新しいタブ(URLコピー)", image: UIImage(named: "option_menu_copy"), action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    PageHistoryDataModel.s.copy()
                    return nil
                }),
                OptionMenuItem(title: "履歴", image: UIImage(named: "option_menu_history"), action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    CommonHistoryDataModel.s.store()
                    PageHistoryDataModel.s.store()
                    return HistoryMenuViewModel()
                }),
                OptionMenuItem(title: "フォーム", image: UIImage(named: "option_menu_form"), action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in return FormMenuViewModel()
                }),
                OptionMenuItem(title: "ブックマーク", image: R.image.optionmenu_favorite(), action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in return FavoriteMenuViewModel()
                }),
                OptionMenuItem(title: "設定", image: UIImage(named: "option_menu_setting"), action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in return SettingMenuViewModel()
                }),
                OptionMenuItem(title: "ヘルプ", image: UIImage(named: "option_menu_help"), action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in return HelpMenuViewModel()
                }),
                OptionMenuItem(title: "アプリ情報", image: R.image.optionmenu_app()),
            ]
        ]
    }
}
