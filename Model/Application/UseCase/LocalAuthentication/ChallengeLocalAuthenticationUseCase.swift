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

    public init() {}

    public func exe() -> Observable<LABiometryType> {
        if LocalAuthenticationService.canUseFaceID() || LocalAuthenticationService.canUseTouchID() {
            return LocalAuthenticationService.challengeWithBiometry()
        } else if LocalAuthenticationService.canUseDevicePasscode() {
            return LocalAuthenticationService.challenge()
        } else {
            return Observable.create { observable in
                observable.onError(NSError.empty)
                return Disposables.create()
            }
        }
    }
}
