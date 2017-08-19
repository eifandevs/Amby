//
//  HelpMenuViewModel.swift
//  Qas
//
//  Created by temma on 2017/08/20.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class HelpMenuViewModel: OptionMenuTableViewModel {
    override init() {
        super.init()
    }
    
    override func setup() {
        menuItems = [
            [
                OptionMenuItem(title: "フォームについて", action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    return nil
                }),
                OptionMenuItem(title: "自動スクロールについて", action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    return nil
                }),
                OptionMenuItem(title: "タブ間を移動する", action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    return nil
                }),
                OptionMenuItem(title: "タブを削除する", action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    return nil
                }),
                OptionMenuItem(title: "タブを複製する", action: { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    return nil
                })
            ]
        ]
    }
}
