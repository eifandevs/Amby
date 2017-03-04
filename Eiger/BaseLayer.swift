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
    private let kHeaderSizeMax: CGFloat = DeviceDataManager.shared.statusBarHeight * 2.4
    
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

        _ = baseView.scrollSpeed.observeNext { [weak self] value in
            //            if value < -(self!.kDecelerationSpeedJudge), self!.expanded == false {
            //                self!.expanded = true
            //            } else if value > self!.kDecelerationSpeedJudge, self!.expanded == true {
            //                self!.expanded = false
            //            }
            // ロード
            
            let slide = { [weak self] (val: CGFloat) -> Void in
                self!.headerView.frame.size.height += value
//                self!.baseView.frame.size.height -= value
                self!.baseView.frame.origin.y += value
                self!.baseView.scroll(pt: -val)
            }
            
            if self!.headerView.frame.size.height != self!.kHeaderSizeMax && value > 0 {
                // headerViewを拡大、baseViewを縮小
                if self!.headerView.frame.size.height + value > self!.kHeaderSizeMax {
                    self!.headerView.frame.size.height = self!.kHeaderSizeMax
//                    self!.baseView.frame.size.height = self!.frame.size.height - self!.kHeaderSizeMax
                    self!.baseView.frame.origin.y = self!.kHeaderSizeMax
                } else {
                    slide(value)
                }
            }
                
            if self!.headerView.frame.size.height != DeviceDataManager.shared.statusBarHeight && value < 0 {
                // headerを縮小、baseViewを拡大
                if self!.headerView.frame.size.height + value < DeviceDataManager.shared.statusBarHeight {
                    self!.headerView.frame.size.height = DeviceDataManager.shared.statusBarHeight
//                    self!.baseView.frame.size.height = self!.frame.size.height - DeviceDataManager.shared.statusBarHeight
                    self!.baseView.frame.origin.y = DeviceDataManager.shared.statusBarHeight
                } else {
                    slide(value)
                }
            }
            
            self!.headerView.frame.origin.y = 0
            
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
