//
//  SettingMenuViewModel.swift
//  Weasel
//
//  Created by User on 2017/06/13.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

class SettingMenuViewModel: OptionMenuTableViewModel {
    override init() {
        super.init()
        menuItems = [
            [
                OptionMenuItem(titleText: "aaaaa", urlText: nil, thumbnailImage: nil),
                OptionMenuItem(titleText: "bbbbb", urlText: nil, thumbnailImage: nil)
            ]
        ]
        actionItems = [
            { () -> OptionMenuTableViewModel? in
                log.warning("tapped!!!!!")
                return nil
            },
            { () -> OptionMenuTableViewModel? in
                log.warning("tapped!!!!!")
                return nil
            }
        ]
    }
}
