//
//  OptionMenuSettingSwitchTableViewCellViewModel.swift
//  Amby
//
//  Created by tenma on 2018/11/08.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import Model

final class OptionMenuSettingSwitchTableViewCellViewModel {
    /// 新規ウィンドウ許諾フラグ
    var newWindowConfirm: Bool {
        return GetSettingUseCase.s.newWindowConfirm
    }

    /// 新規ウィンドウ許諾フラグ変更
    func changeValue(value: Bool) {
        GetSettingUseCase.s.newWindowConfirm = value
    }
}
