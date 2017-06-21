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
        menuItems = [
            [
                OptionMenuItem(titleText: "aaaaa", urlText: nil, image: UIImage(named: "historyforward_webview")),
                OptionMenuItem(titleText: "bbbbb", urlText: nil, image: UIImage(named: "historyforward_webview"))
            ]
        ]
        actionItems = [
            [
                { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    log.warning("tapped!!!!!")
                    return nil
                },
                { (menuItem: OptionMenuItem) -> OptionMenuTableViewModel? in
                    log.warning("tapped!!!!!")
                    return nil
                }
            ]
        ]
    }
}
