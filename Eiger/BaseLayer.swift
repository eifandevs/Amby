//
//  BaseLayer.swift
//  Eiger
//
//  Created by tenma on 2017/03/02.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit
import TextFieldEffects

class BaseLayer: UIView, HeaderViewDelegate {
    
    private let baseView: BaseView = BaseView()
    private let headerView: HeaderView = HeaderView(frame: CGRect.zero)
    private let footerView: FooterView = FooterView()
    private var progressBar: EGProgressBar = EGProgressBar(min: CGFloat(AppDataManager.shared.progressMin))
    private var overlay: UIButton? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        baseView.frame = CGRect(x: 0, y: DeviceDataManager.shared.statusBarHeight, width: frame.size.width, height: frame.size.height - DeviceDataManager.shared.statusBarHeight)
        // サイズが可変なので、layoutSubViewsで初期化しない
        headerView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: DeviceDataManager.shared.statusBarHeight)
        headerView.delegate = self
        
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
        
        let resizeHeaderToMax = { [weak self] in
            self!.headerView.resizeToMax()
            self!.baseView.frame.origin.y = self!.headerView.heightMax
            self!.progressBar.frame = CGRect(x: 0, y: self!.headerView.frame.size.height - 2.1, width: frame.size.width, height: 2.1)
        }
        
        let resizeHeaderToMin = { [weak self] in
            self!.headerView.resizeToMin()
            self!.baseView.frame.origin.y = DeviceDataManager.shared.statusBarHeight
            self!.progressBar.frame = CGRect(x: 0, y: self!.headerView.frame.size.height - 2.1, width: frame.size.width, height: 2.1)
        }
        
        let slide = { [weak self] (val: CGFloat) -> Void in
            self!.headerView.resize(value: val)
            self!.baseView.frame.origin.y += val
            self!.baseView.scroll(pt: -val)
        }
        
        _ = baseView.headerFieldText.observeNext { [weak self] value in
            DispatchQueue.mainSyncSafe(execute: {
                self!.headerView.text = value
            })
        }
        _ = baseView.isTouching.observeNext { [weak self] value in
            // タッチ終了時にheaderViewのサイズを調整する
            if self!.headerView.resizing {
                if self!.headerView.frame.size.height > self!.headerView.heightMax / 2 {
                    UIView.animate(withDuration: 0.2, animations: {
                        resizeHeaderToMax()
                    })
                } else {
                    UIView.animate(withDuration: 0.2, animations: {
                        resizeHeaderToMin()
                    })
                }
            }
        }
        
        _ = baseView.progress.observeNext { [weak self] value in
            self!.progressBar.setProgress(value)
        }
        
        _ = baseView.scrollSpeed.observeNext { [weak self] value in
            if self!.headerView.frame.size.height >= self!.headerView.heightMax {
                self!.headerView.fieldAlpha = 1
            } else {
                if value > 0 {
                    // headerViewを拡大、baseViewを縮小
                    if self!.headerView.frame.size.height + value > self!.headerView.heightMax {
                        resizeHeaderToMax()
                    } else {
                        slide(value)
                    }
                }
            }
            
            if self!.headerView.frame.size.height <= DeviceDataManager.shared.statusBarHeight {
                self!.headerView.fieldAlpha = 0
            } else {
                if value < 0 {
                    // headerを縮小、baseViewを拡大
                    if self!.headerView.frame.size.height + value < DeviceDataManager.shared.statusBarHeight {
                        resizeHeaderToMin()
                    } else {
                        slide(value)
                    }
                }
            }
            
            self!.headerView.frame.origin.y = 0
        }
        
        addSubview(baseView)
        addSubview(headerView)
        addSubview(footerView)
        headerView.addSubview(progressBar)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        footerView.frame = CGRect(x: 0, y: frame.size.height - DeviceDataManager.shared.statusBarHeight * 5, width: frame.size.width, height: DeviceDataManager.shared.statusBarHeight * 5)
        progressBar.frame = CGRect(x: 0, y: headerView.frame.size.height - 2.1, width: frame.size.width, height: 2.1)
    }
    
    func stopProgressObserving() {
        baseView.stopProgressObserving()
    }
    
    func applicationWillResignActive() {
        baseView.storeHistory()
    }
    
    func applicationDidBecomeActive() {
        // プログレスバーの初期化
        progressBar.setProgress(0)
    }
    
// MARK: HeaderView Delegate
    
    func textFieldDidBeginEditing() {
        overlay = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: self.headerView.frame.size.height), size: CGSize(width: frame.size.width, height: frame.size.height - self.headerView.frame.size.height)))
        overlay!.backgroundColor = UIColor.gray
        _ = overlay!.reactive.controlEvents(.touchDown)
            .observeNext { [weak self] _ in
                self!.overlay!.removeFromSuperview()
                self!.overlay = nil
                self!.headerView.finishEditing(force: true)
        }
        addSubview(overlay!)
    }
    
    func textFieldDidEndEditing() {
        overlay!.removeFromSuperview()
        overlay = nil
        headerView.finishEditing(force: false)
    }
}
