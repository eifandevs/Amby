//
//  FBLoginService.swift
//  Amby
//
//  Created by tenma.i on 2019/10/16.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import Foundation
import GoogleSignIn
import Hydra
import Model

/// Firebaseログイン
class FBLoginService {
    var isLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }

    func signIn(credential: AuthCredential) -> Promise<Bool> {
        return Promise<Bool>(in: .main, token: nil) { resolve, reject, _ in
            Auth.auth().signIn(with: credential) { _, error in
                if let error = error {
                    log.error("firebase signIn error. error: \(error.localizedDescription)")
                    reject(error)
                } else {
                    log.debug("firebase signIn success. userid: \(Auth.auth().currentUser!.uid)")
                    SettingAccessUseCase().loginProvider = .facebook
                    resolve(true)
                }
            }
        }
    }

    func signIn(_: GIDSignIn!, didSignInFor user: GIDGoogleUser!) -> Promise<Bool> {
        return Promise<Bool>(in: .main, token: nil) { resolve, reject, _ in
            // Perform any operations on signed in user here.
            let userId = user.userID // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            log.debug("userId: \(userId ?? "") idToken: \(idToken) fullName: \(fullName) givenName: \(givenName) familyName: \(familyName) email: \(email)")
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                           accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { _, error in
                if let error = error {
                    log.error("firebase signIn error. error: \(error.localizedDescription)")
                    reject(error)
                } else {
                    log.debug("firebase login success. userid: \(Auth.auth().currentUser!.uid)")
                    SettingAccessUseCase().loginProvider = .google
                    resolve(true)
                }
            }
        }
    }

    func signOutSilent() {
        // logout firebase
        try! Auth.auth().signOut()

        // logout provider
        let loginProvider = SettingAccessUseCase().loginProvider
        switch loginProvider {
        case .google:
            log.debug("logout google")
            GIDSignIn.sharedInstance()?.signOut()
        case .facebook:
            log.debug("logout facebook")
            LoginManager().logOut()
        case .twitter:
            log.debug("logout twitter")
        case .none:
            log.error("logout failed. not login")
        }
    }

    func signOut() {
        signOutSilent()
        // TODO: delete user token
        NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.LOG_OUT_SUCCESS, isSuccess: true)
    }

    func deleteAccount() {
        if !isLoggedIn {
            NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.DELETE_ACCOUNT_ERROR_NOT_LOGGED_IN, isSuccess: false)
            return
        }

        NotificationService.presentAlert(title: MessageConst.NOTIFICATION.ACCOUNT_DELETE, message: MessageConst.NOTIFICATION.ACCOUNT_DELETE_MESSAGE) {
            Auth.auth().currentUser?.delete(completion: { [weak self] error in
                if let error = error {
                    log.error("delete account faild. error: \(error)")
                    NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.DELETE_ACCOUNT_ERROR, isSuccess: false)
                    return
                }
                log.debug("delete account success.")
                // logout provider
                let loginProvider = SettingAccessUseCase().loginProvider
                switch loginProvider {
                case .google:
                    log.debug("logout google")
                    GIDSignIn.sharedInstance()?.signOut()
                case .facebook:
                    log.debug("logout facebook")
                    LoginManager().logOut()
                case .twitter:
                    log.debug("logout twitter")
                case .none:
                    log.error("logout failed. not login")
                }
                NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.DELETE_ACCOUNT_SUCCESS, isSuccess: true)
            })
        }
    }
}
