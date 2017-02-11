//
//  ViewController.swift
//  Eiger
//
//  Created by temma on 2017/01/29.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    private let baseView: BaseView = BaseView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillResignActive),
            name: NSNotification.Name("UIApplicationWillResignActiveNotification"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: NSNotification.Name("UIApplicationDidBecomeActiveNotification"),
            object: nil
        )
        view = baseView
    }

    func applicationWillResignActive() {
        log.debug("store history")
        baseView.storeHistory()
    }
    
    func applicationDidBecomeActive() {
        baseView.initializeProgress()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        baseView.stopProgressObserving()
    }
    
    override func viewDidLayoutSubviews() {
        self.view.frame = CGRect(origin: CGPoint(x: 0, y: DeviceDataManager.shared.statusBarHeight), size: self.view.bounds.size)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

