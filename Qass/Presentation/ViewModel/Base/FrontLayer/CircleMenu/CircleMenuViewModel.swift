//
//  CircleMenuViewModel.swift
//  Qass
//
//  Created by tenma on 2018/07/08.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import Model

final class CircleMenuViewModel {
    var menuItems: [[UserOperation]] {
        return [SettingUseCase.s.menuOrder[0 ... 5].map { $0 }, SettingUseCase.s.menuOrder[6 ... 11].map { $0 }]
    }

    var menuIndex = 0
}
