//
//  SyncViewController.swift
//  Amby
//
//  Created by iori tenma on 2019/06/15.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn
import SnapKit
import UIKit

class SyncViewController: UIViewController {
    @IBOutlet var closeButton: CornerRadiusButton!
    @IBOutlet var facebookReAuthButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        let loginButton = FBLoginButton()
        loginButton.delegate = self
        loginButton.permissions = ["email"]
        loginButton.frame = CGRect(x: 0, y: 0, width: 100, height: 60)
        view.addSubview(loginButton)

        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance()?.delegate = self

        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 0, y: 300, width: 100, height: 60)
        view.addSubview(googleButton)

        // ボタンタップ
        facebookReAuthButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                let manager = LoginManager()
                manager.logOut()
                manager.authType = .reauthorize
                manager.logIn(permissions: ["email"], from: nil) { _, error in
                    if let error = error {
                        NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.LOG_IN_ERROR, isSuccess: false)
                        log.error("facebook signIn error. error: \(error)")
                    } else {
                        if let current = AccessToken.current {
                            let credential = FacebookAuthProvider.credential(withAccessToken: current.tokenString)
                            LoginService().signIn(credential: credential)
                                .then { _ in
                                    NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.LOG_IN_SUCCESS, isSuccess: true)
                                    log.debug("facebook signIn success")
                                    // TODO: ログイン
                                }.catch { _ in
                                    NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.LOG_IN_ERROR, isSuccess: false)
                                    log.error("facebook signIn error")
                                }
                        } else {
                            NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.LOG_IN_ERROR, isSuccess: false)
                            log.error("facebook signIn error. not exist current")
                        }
                    }
                }
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)

        // ボタンタップ
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
    }

    // 追記部分(デリゲートメソッド)エラー来た時
    func sign(_: GIDSignIn!, didDisconnectWith _: GIDGoogleUser!,
              withError error: Error!) {
        log.error(error.localizedDescription)
    }
}

extension SyncViewController: GIDSignInUIDelegate, GIDSignInDelegate {
    func sign(_: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.LOG_IN_ERROR, isSuccess: false)
            log.error("google signIn error. error: \(error)")
        } else {
            LoginService().signIn(nil, didSignInFor: user)
                .then { _ in
                    NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.LOG_IN_SUCCESS, isSuccess: true)
                    // TODO: ログイン
                }.catch { _ in
                    NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.LOG_IN_ERROR, isSuccess: false)
                }
        }
    }
}

extension SyncViewController: LoginButtonDelegate {
    func loginButton(_: FBLoginButton, didCompleteWith _: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.LOG_IN_ERROR, isSuccess: false)
            log.error("facebook signIn error. error: \(error)")
        } else {
            if let current = AccessToken.current {
                let credential = FacebookAuthProvider.credential(withAccessToken: current.tokenString)
                LoginService().signIn(credential: credential)
                    .then { _ in
                        NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.LOG_IN_SUCCESS, isSuccess: true)
                        log.debug("facebook signIn success")
                        // TODO: ログイン
                    }.catch { _ in
                        NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.LOG_IN_ERROR, isSuccess: false)
                        log.error("facebook signIn error")
                    }
            } else {
                NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.LOG_IN_ERROR, isSuccess: false)
                log.error("facebook signIn error. not exist current")
            }
        }
    }

    func loginButtonDidLogOut(_: FBLoginButton) {}
}
