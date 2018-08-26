//
//  SettingUseCase.swift
//  Qass
//
//  Created by tenma on 2018/08/27.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/// 設定ユースケース
final class SettingUseCase {

    static let s = SettingUseCase()

    private init() {}

    func setup() {
        SettingDataModel.s.setup()
    }
}
