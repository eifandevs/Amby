//
//  OptionMenuFormTableViewCellViewModel.swift
//  Amby
//
//  Created by tenma on 2018/10/29.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import Model

final class OptionMenuFormTableViewCellViewModel {
    var form: Form!

    /// 閲覧リクエスト
    func readForm(id: String) {
        if PasscodeUseCase.s.authentificationChallenge() {
            FormUseCase.s.read(id: id)
        }
    }
}
