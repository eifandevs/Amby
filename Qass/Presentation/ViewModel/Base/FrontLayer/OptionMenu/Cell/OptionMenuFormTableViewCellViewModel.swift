//
//  OptionMenuFormTableViewCellViewModel.swift
//  Qass
//
//  Created by tenma on 2018/10/29.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import Model

final class OptionMenuFormTableViewCellViewModel {
    /// 閲覧リクエスト
    func readForm(id: String) {
        if PasscodeUseCase.s.isRegisterdPasscode {
            if PasscodeUseCase.s.isInputPasscode {
                // パスコード入力済みの場合は表示
                FormUseCase.s.read(id: id)
            } else {
                PasscodeUseCase.s.confirm()
            }
        } else {
            NotificationManager.presentToastNotification(message: MessageConst.NOTIFICATION.PASSCODE_NOT_REGISTERED, isSuccess: false)
        }
    }
}
