//
//  AppDelegate.swift
//  Eiger
//
//  Created by temma on 2017/01/29.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Firebase
import GoogleSignIn
import Logger
import Model
import SVProgressHUD
import UIKit

let log = AppLogger.self

/// クラッシュ時にスタックトレースを表示する
let uncaughtExceptionHandler: Void = NSSetUncaughtExceptionHandler { exception in
    log.error("Name: \(exception.name.rawValue)")
    if let reason = exception.reason {
        log.error("Reason: \(exception.reason!)")
    }
    log.error("Symbols: \(exception.callStackSymbols)")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    var window: UIWindow?
    var baseViewController: BaseViewController?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // log setup
        Logger.setup()

        // model setup
        Model.setup()

        #if RELEASE
            log.info("RELEASE BUILD")
        #else
            UIViewController.swizzle() // ログ出力
            #if DEBUG
                log.info("DEBUG BUILD")
            #endif

            #if UT
                log.info("UT BUILD")
            #endif

            #if STAGING
                log.info("STAGING BUILD")
            #endif

            #if LOCAL
                log.info("LOCAL BUILD")
            #endif
        #endif

        log.verbose("DOCUMENT PATH: \(AppConst.DEVICE.DOCUMENT_PATH)")
        log.verbose("BUNDLE PATH: \(AppConst.DEVICE.BUNDLE_PATH)")
        log.verbose("APPLICATION PATH: \(AppConst.DEVICE.APPLICATION_PATH)")

        // progress setup
        SVProgressHUD.setForegroundColor(UIColor.ultraViolet)

        // view setup
        setup()

        #if RELEASE
            // tracking service
            TrackingService.setup()

            // google sign in
            GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
            GIDSignIn.sharedInstance()?.delegate = self
        #endif

        return true
    }

    private func setup() {
        window = UIWindow(frame: UIScreen.main.bounds)
        baseViewController = BaseViewController()
        window!.rootViewController = baseViewController!
        window!.backgroundColor = UIColor.white
        window!.makeKeyAndVisible()
    }

    func initialize() {
        GetSettingUseCase().initialize()

        if let baseViewController = self.window!.rootViewController as? BaseViewController {
            baseViewController.mRelease()
        }
        window!.rootViewController?.view.removeAllSubviews()
        window!.rootViewController?.view.removeFromSuperview()
        window!.rootViewController?.removeFromParentViewController()
        window!.rootViewController = nil

        // プログレス表示
        SVProgressHUD.show()

        // 各サブビューのdismissがコールされるのを待つ
        SVProgressHUD.dismiss(withDelay: 2.5) {
            self.window!.rootViewController = BaseViewController()
        }
    }

    // MARK: App Delegate

    func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        ExpireCheckHistoryUseCase().exe()
        ExpireCheckSearchUseCase().exe()
    }

    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

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

    // 追記部分(デリゲートメソッド)エラー来た時
    func sign(_: GIDSignIn!, didDisconnectWith _: GIDGoogleUser!,
              withError error: Error!) {
        log.error(error.localizedDescription)
    }

    func application(_: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: [:])
    }
}
