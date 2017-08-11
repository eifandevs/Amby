//
//  AppDelegate.swift
//  Eiger
//
//  Created by temma on 2017/01/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit
import SwiftyBeaver
import Onboard

let log = SwiftyBeaver.self

/// クラッシュ時にスタックトレースを表示する
let uncaughtExceptionHandler : Void = NSSetUncaughtExceptionHandler { exception in
    log.error("Name: \(exception.name.rawValue)")
    if let reason = exception.reason {
        log.error("Reason: \(exception.reason!)")
    }
    log.error("Symbols: \(exception.callStackSymbols)")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // ログ設定
        // SwiftyBeaver
        let console = ConsoleDestination()  // log to Xcode Console
        let file = FileDestination()  // log to default swiftybeaver.log file
        
        #if DEBUG
            console.minLevel = log.Level.verbose
            file.minLevel = log.Level.verbose
        #else
            console.minLevel = log.Level.error
            file.minLevel = log.Level.error
        #endif
        
        console.format = "$DHH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"
        
        log.addDestination(console)
        log.addDestination(file)
        
        // ユーザーデフォルト初期値設定
        CommonDao.s.registerDefaultData()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let baseVC = boardingViewController()
        self.window!.rootViewController = baseVC
        self.window!.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.window!.makeKeyAndVisible()
        
        return true
    }
    
    func initialize() {
        UserDefaults.standard.set(0, forKey: AppConst.locationIndexKey)
        UserDefaults.standard.set(0.06, forKey: AppConst.autoScrollIntervalKey)
        self.window!.rootViewController?.removeFromParentViewController()
        self.window!.rootViewController = BaseViewController()
    }
    
    func boardingViewController() -> OnboardingViewController {
        let content1 = OnboardingContentViewController(title: "チュートリアル", body: "最高のブラウザ", image: nil, buttonText: nil, action: nil)
        let content2 = OnboardingContentViewController(title: "チュートリアル", body: "最高のブラウザ2", image: nil, buttonText: nil, action: nil)
        let content3 = OnboardingContentViewController(title: "チュートリアル", body: "最高のブラウザ", image: nil, buttonText: "スタート") {
            (UIApplication.shared.delegate as! AppDelegate).initialize()
        }
        let onBoardingVC = OnboardingViewController(backgroundImage: R.image.onboard_back(), contents: [content1, content2, content3])!
        onBoardingVC.allowSkipping = true
        onBoardingVC.skipButton.addTarget(self, action: #selector(self.onTappedSkipButton(_:)), for: .touchUpInside)
        onBoardingVC.shouldBlurBackground = false
        onBoardingVC.shouldFadeTransitions = false
        return onBoardingVC
    }

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
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
// MARK: Button Event
    func onTappedSkipButton(_ sender: AnyObject) {
        (UIApplication.shared.delegate as! AppDelegate).initialize()
    }
}
