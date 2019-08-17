//
//  CircleMenuViewModel.swift
//  Amby
//
//  Created by tenma on 2018/07/08.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import Model

final class CircleMenuViewModel {
    var menuItems: [[UserOperation]] {
        let menuOrder = GetSettingUseCase().menuOrder
        return (1 ... AppConst.FRONT_LAYER.CIRCLEMENU_SECTION_NUM).map { menuOrder[(AppConst.FRONT_LAYER.CIRCLEMENU_ROW_NUM * ($0 - 1)) ... (AppConst.FRONT_LAYER.CIRCLEMENU_ROW_NUM * $0 - 1)].map { $0 } }
    }

    var menuIndex = 0
}
