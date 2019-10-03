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

    public func exe() -> Observable<RepositoryResult<LABiometryType>> {
        var error: NSError?
        if LocalAuthenticationService.canUseFaceID(error: &error) == false && LocalAuthenticationService.canUseTouchID(error: &error) == false {
            LocalAuthenticationHandlerUseCase.s.noticeCannotUse()
            return Observable.create { observable in
                observable.onNext(.failure(NSError.empty))
                return Disposables.create()
            }
        }

        return LocalAuthenticationService.challenge().flatMap { result -> Observable<RepositoryResult<LABiometryType>> in
            if case .failure = result {
                LocalAuthenticationHandlerUseCase.s.noticeCannotUse()
            }
            return Observable.just(result)
        }
    }
}
