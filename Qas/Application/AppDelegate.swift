//
//  AppDelegate.swift
//  Eiger
//
//  Created by temma on 2017/01/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit
import Dollar
import SVProgressHUD

let log = Logger.self
let D = `$`.self

/// クラッシュ時にスタックトレースを表示する
let uncaughtExceptionHandler: Void = NSSetUncaughtExceptionHandler { exception in
    log.error("Name: \(exception.name.rawValue)")
    if let reason = exception.reason {
        log.error("Reason: \(exception.reason!)")
    }
    log.error("Symbols: \(exception.callStackSymbols)")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var baseViewController: BaseViewController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // ログ設定
        log.setup()

        #if DEVELOP
            log.info("DEVELOP TARGET")
        #else
            log.info("PRODUCTION TARGET")
        #endif

        #if DEBUG
            UIViewController.swizzle() // ログ出力
            #if LOCAL
                log.info("DEBUG LOCAL BUILD")
            #elseif UT
                log.info("DEBUG UT BUILD")
            #else
                log.info("DEBUG BUILD")
            #endif
        #endif

        #if RELEASE
            log.info("RELEASE BUILD")
        #endif
        
        // プログレス初期設定
        SVProgressHUD.setForegroundColor(UIColor.brilliantBlue)
        
        // 初回起動時のみキーチェーンにトークンを保存
        if KeyChainHelper.getToken(key: AppConst.KEY_REALM_TOKEN) == nil {
            let token = String.getRandomStringWithLength(length: 64)
            log.debug("Realmトークンを作成します。token: \(token)")
            KeyChainHelper.saveToken(key: AppConst.KEY_REALM_TOKEN, value: token)
        }
        if KeyChainHelper.getToken(key: AppConst.KEY_ENCRYPT_SERVICE_TOKEN) == nil {
            let token = String.getRandomStringWithLength(length: 32)
            log.debug("Encrypt Serviceトークンを作成します。token: \(token)")
            KeyChainHelper.saveToken(key: AppConst.KEY_ENCRYPT_SERVICE_TOKEN, value: token)
        }
        if KeyChainHelper.getToken(key: AppConst.KEY_ENCRYPT_IV_TOKEN) == nil {
            let token = String.getRandomStringWithLength(length: 16)
            log.debug("Encrypt Ivトークンを作成します。token: \(token)")
            KeyChainHelper.saveToken(key: AppConst.KEY_ENCRYPT_IV_TOKEN, value: token)
        }

        // ユーザーデフォルト初期値設定
        CommonDao.s.registerDefaultData()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        baseViewController = BaseViewController()
        self.window!.rootViewController = baseViewController!
        self.window!.backgroundColor = UIColor.white
        self.window!.makeKeyAndVisible()
        
        return true
    }
    
    func initialize() {
        UserDefaults.standard.set(AppConst.UD_LOCATION_INDEX, forKey: AppConst.KEY_LOCATION_INDEX)
        UserDefaults.standard.set(AppConst.UD_CURRENT_CONTEXT, forKey: AppConst.KEY_CURRENT_CONTEXT)
        UserDefaults.standard.set(AppConst.UD_AUTO_SCROLL, forKey: AppConst.KEY_AUTO_SCROLL_INTERVAL)
        UserDefaults.standard.set(AppConst.UD_COMMON_HISTORY_SAVE_COUNT, forKey: AppConst.KEY_COMMON_HISTORY_SAVE_COUNT)
        UserDefaults.standard.set(AppConst.UD_PAGE_HISTORY_SAVE_COUNT, forKey: AppConst.KEY_PAGE_HISTORY_SAVE_COUNT)
        UserDefaults.standard.set(AppConst.UD_SEARCH_HISTORY_SAVE_COUNT, forKey: AppConst.KEY_SEARCH_HISTORY_SAVE_COUNT)
        if let baseViewController = self.window!.rootViewController as? BaseViewController {
            baseViewController.mRelease()
        }
        self.window!.rootViewController?.view.removeAllSubviews()
        self.window!.rootViewController?.view.removeFromSuperview()
        self.window!.rootViewController?.removeFromParentViewController()
        self.window!.rootViewController = nil
        
        // プログレス表示
        SVProgressHUD.show()
        
        // 各サブビューのdismissがコールされるのを待つ
        SVProgressHUD.dismiss(withDelay: 2.5) {
            self.window!.rootViewController = BaseViewController()
        }
    }

// MARK: App Delegate
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        CommonHistoryDataModel.s.expireCheck()
        SearchHistoryDataModel.s.expireCheck()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
