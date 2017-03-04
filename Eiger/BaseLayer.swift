//
//  BaseLayer.swift
//  Eiger
//
//  Created by tenma on 2017/03/02.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class BaseLayer: UIView {
    
    private var baseView: BaseView! = nil
    private var headerView: HeaderView = HeaderView()
    private let kDecelerationSpeedJudge: CGFloat = 2.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        baseView = BaseView(frame: CGRect(x: 0, y: DeviceDataManager.shared.statusBarHeight, width: frame.size.width, height: frame.size.height - DeviceDataManager.shared.statusBarHeight))
        headerView = HeaderView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: DeviceDataManager.shared.statusBarHeight))
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
        
        _ = baseView.decelerationSpeed.observeNext { [weak self] value in
            //            if value < -(self!.kDecelerationSpeedJudge), self!.expanded == false {
            //                self!.expanded = true
            //            } else if value > self!.kDecelerationSpeedJudge, self!.expanded == true {
            //                self!.expanded = false
            //            }
            // ロード
            log.debug("speed: \(value)")
        }
        
        addSubview(baseView)
        addSubview(headerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func stopProgressObserving() {
        baseView.stopProgressObserving()
    }
    
    func applicationWillResignActive() {
        baseView.storeHistory()
    }
    
    func applicationDidBecomeActive() {
        baseView.initializeProgress()
    }
}
