//
//  SettingMenuViewModel.swift
//  Weasel
//
//  Created by User on 2017/06/13.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class SettingMenuViewModel: OptionMenuTableViewModel {
    override init() {
        super.init()
    }
    
    override func setup() {
        sectionItems = ["初期表示URL", "データ保持設定", "自動スクロール設定", "データ削除"]
        menuItems = [
            [
                OptionMenuItem(type: .input)
            ],
            [
                OptionMenuItem(type: .select, title: "閲覧履歴を記録する"),
                OptionMenuItem(type: .select, title: "キャッシュを利用する")
            ],
            [
                OptionMenuItem(title: "bbbb")
            ],
            [
                OptionMenuItem(title: "bbbb")
            ]
        ]
    }
}
