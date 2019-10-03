//
//  LocalAuthenticationService.swift
//  Model
//
//  Created by tenma.i on 2019/09/27.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import LocalAuthentication
import RxSwift
import CommonUtil

class LocalAuthenticationService {

    class func challenge() -> Observable<RepositoryResult<LABiometryType>> {
        let context = LAContext()
        var error: NSError?
        let description: String = "認証します"

        return Observable.create { observable in
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: description, reply: {success, _ in
                    if (success) {
                        // 認証成功
                        observable.onNext(.success(context.biometryType))
                    } else {
                        observable.onNext(.failure(NSError.empty))
                    }
                })
            } else {
                observable.onNext(.failure(NSError.empty))
            }
            return Disposables.create()
        }
    }

    /**
     Face IDが利用出来るかチェックします
     
     - returns Bool: true 利用可能 / false 利用不可
     */
    class func canUseFaceID(error: inout NSError?) -> Bool {
        if #available(iOS 11.0, *) {
            let context = LAContext()
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                if context.biometryType == .faceID {
                    return true
                }
            }
        }

        return false
    }

    /**
     Touch IDが利用できるかチェックします
     
     - returns Bool: true 利用可能 / false 利用不可
     */
    class func canUseTouchID(error: inout NSError?) -> Bool {
        let context = LAContext()

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            if #available(iOS 11.0, *) {
                if context.biometryType == .touchID {
                    return true
                }
            } else if #available(iOS 8.0, *) {
                return true
            }
        }

        return false
    }
}
