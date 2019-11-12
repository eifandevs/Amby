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
import RxCocoa
import RxSwift
import SnapKit
import UIKit

class SyncViewController: UIViewController {
    @IBOutlet var closeButton: CornerRadiusButton!
    @IBOutlet var facebookReAuthButton: UIButton!
    @IBOutlet var twitterReAuthButton: UIButton!
    @IBOutlet var googleReAuthButton: UIButton!

    let viewModel = SyncViewControllerViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance()?.delegate = self

        googleReAuthButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                GIDSignIn.sharedInstance()?.signIn()
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)

        facebookReAuthButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                let manager = LoginManager()
                manager.authType = .reauthorize // not work
                manager.logIn(permissions: ["email"], from: nil) { _, error in
                    if let error = error {
                        NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.LOG_IN_ERROR, isSuccess: false)
                        log.error("facebook signIn error. error: \(error)")
                    } else {
                        if let current = AccessToken.current {
                            let credential = FacebookAuthProvider.credential(withAccessToken: current.tokenString)
                            FBLoginService().signIn(credential: credential)
                                .then { _ in
                                    self.appSignIn()
                                }.catch { _ in
                                    NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.LOG_IN_ERROR, isSuccess: false)
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

        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
    }

    private func appSignIn() {
        // app login
        if let uid = Auth.auth().currentUser?.uid {
            viewModel.login(uid: Auth.auth().currentUser!.uid).subscribe { [weak self] result in
                switch result {
                case .success:
                    log.debug("app signIn success")
                    NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.LOG_IN_SUCCESS, isSuccess: true)
                case .error:
                    log.error("app signIn error")
                    NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.LOG_IN_ERROR, isSuccess: false)
                }
            }.disposed(by: disposeBag)
        } else {
            log.error("app signIn error. not exist currentUser")
        }
    }
}

extension SyncViewController: GIDSignInDelegate {
    func sign(_: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.LOG_IN_ERROR, isSuccess: false)
            log.error("google signIn error. error: \(error)")
        } else {
            FBLoginService().signIn(nil, didSignInFor: user)
                .then { _ in
                    self.appSignIn()
                }.catch { _ in
                    NotificationService.presentToastNotification(message: MessageConst.NOTIFICATION.LOG_IN_ERROR, isSuccess: false)
                }
        }
    }

    // 追記部分(デリゲートメソッド)エラー来た時
    func sign(_: GIDSignIn!, didDisconnectWith _: GIDGoogleUser!,
              withError error: Error!) {
        log.error("google signIn error. error: \(error)")
        log.error(error.localizedDescription)
    }
}
