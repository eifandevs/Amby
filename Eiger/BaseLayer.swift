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

class BaseLayer: UIView, UITextFieldDelegate {
    
    private let baseView: BaseView = BaseView()
    private let headerView: HeaderView = HeaderView()
    private let footerView: FooterView = FooterView()
    private var progressBar: EGProgressBar = EGProgressBar(min: CGFloat(AppDataManager.shared.progressMin))
    private var headerField: EGTextField = EGTextField(iconSize: CGSize(width: AppDataManager.shared.headerViewSizeMax * 0.5, height: AppDataManager.shared.headerViewSizeMax * 0.5))
    private let headerViewSizeMax = AppDataManager.shared.headerViewSizeMax
    private var baseViewOverlay: UIButton! = nil
    private var isEditing = false {
        didSet {
            if isEditing {
                UIView.animate(withDuration: 0.11, delay: 0, options: .curveLinear, animations: {
                    self.headerField.frame = self.headerView.frame
                })
            } else {
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                    self.headerField.frame = CGRect(x: 95, y: self.headerView.frame.size.height - self.headerViewSizeMax * 0.63, width: self.frame.size.width - 190, height: self.headerViewSizeMax * 0.5)
                }, completion: nil)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        headerField.text = ""
        headerField.delegate = self
        baseView.frame = CGRect(x: 0, y: DeviceDataManager.shared.statusBarHeight, width: frame.size.width, height: frame.size.height - DeviceDataManager.shared.statusBarHeight)
        // サイズが可変なので、layoutSubViewsで初期化しない
        headerView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: DeviceDataManager.shared.statusBarHeight)
        
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
            self!.headerView.frame.size.height = self!.headerViewSizeMax
            self!.baseView.frame.origin.y = self!.headerViewSizeMax
            self!.headerField.frame = CGRect(x: 95, y: self!.headerView.frame.size.height - self!.headerViewSizeMax * 0.63, width: frame.size.width - 190, height: self!.headerViewSizeMax * 0.5)
            self!.progressBar.frame = CGRect(x: 0, y: self!.headerView.frame.size.height - 2.1, width: frame.size.width, height: 2.1)
            self!.headerField.alpha = 1
        }
        
        let resizeHeaderToMin = { [weak self] in
            self!.headerView.frame.size.height = DeviceDataManager.shared.statusBarHeight
            self!.baseView.frame.origin.y = DeviceDataManager.shared.statusBarHeight
            self!.headerField.frame = CGRect(x: 95, y: self!.headerView.frame.size.height - self!.headerViewSizeMax * 0.63, width: frame.size.width - 190, height: self!.headerViewSizeMax * 0.5)
            self!.progressBar.frame = CGRect(x: 0, y: self!.headerView.frame.size.height - 2.1, width: frame.size.width, height: 2.1)
            self!.headerField.alpha = 0
        }
        
        let slide = { [weak self] (val: CGFloat) -> Void in
            self!.headerField.alpha += val / (self!.headerViewSizeMax - DeviceDataManager.shared.statusBarHeight)
            self!.headerView.frame.size.height += val
            self!.baseView.frame.origin.y += val
            self!.baseView.scroll(pt: -val)
        }
        
        _ = baseView.headerFieldText.observeNext { [weak self] value in
            DispatchQueue.mainSyncSafe(execute: {
                self!.headerField.text = value
            })
        }
        _ = baseView.isTouching.observeNext { [weak self] value in
            // タッチ終了時にheaderViewのサイズを調整する
            if self!.headerView.frame.size.height != DeviceDataManager.shared.statusBarHeight && self!.headerView.frame.size.height != self!.headerViewSizeMax {
                if self!.headerView.frame.size.height > self!.headerViewSizeMax / 2 {
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
            if self!.headerView.frame.size.height >= self!.headerViewSizeMax {
                self!.headerField.alpha = 1
            } else {
                if value > 0 {
                    // headerViewを拡大、baseViewを縮小
                    if self!.headerView.frame.size.height + value > self!.headerViewSizeMax {
                        resizeHeaderToMax()
                    } else {
                        slide(value)
                    }
                }
            }
            
            if self!.headerView.frame.size.height <= DeviceDataManager.shared.statusBarHeight {
                self!.headerField.alpha = 0
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
        headerView.addSubview(headerField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if !isEditing {
            headerField.frame = CGRect(x: 95, y: headerView.frame.size.height - headerViewSizeMax * 0.63, width: frame.size.width - 190, height: headerViewSizeMax * 0.5)
        }
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
    
// MARK: TextField Delegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        isEditing = true
        headerField.removeContent()
        baseViewOverlay = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: headerView.frame.size.height), size: CGSize(width: frame.size.width, height: frame.size.height - headerView.frame.size.height)))
        baseViewOverlay.backgroundColor = UIColor.gray
        _ = baseViewOverlay.reactive.controlEvents(.touchDown)
            .observeNext { [weak self] _ in
                self!.endEditing(true)
                self!.headerField.makeContent(restore: true, restoreText: nil)
                self!.baseViewOverlay.removeFromSuperview()
                self!.baseViewOverlay = nil
        }
        addSubview(baseViewOverlay)

        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isEditing = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        log.debug("textFieldShouldReturn called")
        let text = headerField.superText
        endEditing(true)
        if text == nil || text!.isEmpty {
            headerField.makeContent(restore: true, restoreText: nil)
        } else {
            headerField.makeContent(restore: true, restoreText: text)
        }
        baseViewOverlay.removeFromSuperview()
        baseViewOverlay = nil
        return true
    }
}
