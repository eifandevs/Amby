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

    override func viewDidLoad() {
        super.viewDidLoad()
        let loginButton = FBLoginButton()
        loginButton.delegate = self
//        loginButton.readPermissions = ["public_profile", "email"]
        loginButton.frame = CGRect(x: 0, y: 0, width: 100, height: 60)
        view.addSubview(loginButton)

        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance()?.delegate = self

        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 0, y: 300, width: 100, height: 60)
        view.addSubview(googleButton)

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
        LoginService().signIn(nil, didSignInFor: user, withError: error)
            .then { _ in
                NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.LOG_IN_SUCCESS, isSuccess: true)
                log.debug("signIn success")
                // TODO: ログイン
            }.catch { _ in
                NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.LOG_IN_ERROR, isSuccess: false)
                log.error("signIn error")
            }
    }
}

extension SyncViewController: LoginButtonDelegate {
    func loginButton(_: FBLoginButton, didCompleteWith _: LoginManagerLoginResult?, error _: Error?) {}

    func loginButtonDidLogOut(_: FBLoginButton) {}
}
