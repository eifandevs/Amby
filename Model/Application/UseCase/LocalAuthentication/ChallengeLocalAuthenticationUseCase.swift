//
//  ChallengeLocalAuthenticationUseCase.swift
//  Model
//
//  Created by tenma.i on 2019/09/18.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import LocalAuthentication
import RxSwift

public final class ChallengeLocalAuthenticationUseCase {

    /// passcode setting usecase
    let usecase = GetLocalAuthenticationSettingUseCase()
    let localAuthUseCase = LocalAuthenticationHandlerUseCase.s

    public init() {}

    public func exe() -> Observable<Bool> {
        var error: NSError?
        if LocalAuthenticationService.canUseFaceID(error: &error) == false && LocalAuthenticationService.canUseTouchID(error: &error) == false {
            localAuthUseCase.noticeCannotUse()
            return Observable.create { observable in
                observable.onNext(false)
                return Disposables.create()
            }
        }

        return LocalAuthenticationService.challenge().flatMap { [weak self] success -> Observable<Bool> in
            if success {
                return Observable.just(true)
            } else {
                self?.localAuthUseCase.noticeCannotUse()
                return Observable.just(false)
            }
        }
    }
}
