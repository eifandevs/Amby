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

    class func challenge() -> Observable<LABiometryType> {
        let context = LAContext()
        var error: NSError?
        let description: String = "認証します"

        return Observable.create { observable in
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: description, reply: {success, _ in
                    if (success) {
                        // 認証成功
                        observable.onNext(context.biometryType)
                        observable.onCompleted()
                    } else {
                        observable.onError(NSError.empty)
                    }
                })
            } else {
                observable.onError(NSError.empty)
            }
            return Disposables.create()
        }
    }

    class func challengeWithBiometry() -> Observable<LABiometryType> {
        let context = LAContext()
        var error: NSError?
        let description: String = "認証します"

        return Observable.create { observable in
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: description, reply: {success, _ in
                    if (success) {
                        // 認証成功
                        observable.onNext(context.biometryType)
                        observable.onCompleted()
                    } else {
                        observable.onError(NSError.empty)
                    }
                })
            } else {
                observable.onError(NSError.empty)
            }
            return Disposables.create()
        }
    }

    static func canUseDevicePasscode() -> Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }

    /**
     Face IDが利用出来るかチェックします
     
     - returns Bool: true 利用可能 / false 利用不可
     */
    class func canUseFaceID() -> Bool {
        if #available(iOS 11.0, *) {
            let context = LAContext()
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
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
    class func canUseTouchID() -> Bool {
        let context = LAContext()

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
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
