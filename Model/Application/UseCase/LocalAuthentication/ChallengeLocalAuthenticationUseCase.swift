//
//  ChallengeLocalAuthenticationUseCase.swift
//  Model
//
//  Created by tenma.i on 2019/09/18.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation

public final class ChallengeLocalAuthenticationUseCase {

    /// passcode setting usecase
    let usecase = GetLocalAuthenticationSettingUseCase()
    let localAuthUseCase = LocalAuthenticationHandlerUseCase.s

    public init() {}

    /// 表示可能判定
    public func exe() -> Bool {
        if usecase.isRegisterdPasscode {
            if usecase.isInputPasscode {
                return true
            } else {
                localAuthUseCase.confirm()
            }
        } else {
            localAuthUseCase.noticeNotRegistered()
        }
        return false
    }
}
