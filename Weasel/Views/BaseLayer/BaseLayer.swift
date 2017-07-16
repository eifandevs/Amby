//
//  BaseLayer.swift
//  Eiger
//
//  Created by tenma on 2017/03/02.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

protocol BaseLayerDelegate {
    func baseLayerDidInvalidate(direction: EdgeSwipeDirection)
}

class BaseLayer: UIView, HeaderViewDelegate, BaseViewDelegate {
    
    var delegate: BaseLayerDelegate?
    let headerViewOriginY: (max: CGFloat, min: CGFloat) = (0, -(AppConst.headerViewHeight - DeviceConst.statusBarHeight))
    private var headerView: HeaderView
    private let footerView: FooterView
    private let baseView: BaseView
    private var overlay: UIButton? = nil
    private var isTouchEndAnimating = false

    override init(frame: CGRect) {
        // ヘッダービュー
        headerView = HeaderView(frame: CGRect(x: 0, y: headerViewOriginY.min, width: frame.size.width, height: AppConst.headerViewHeight))
        // フッタービュー
        footerView = FooterView(frame: CGRect(x: 0, y: DeviceConst.displaySize.height - AppConst.thumbnailSize.height, width: frame.size.width, height: AppConst.thumbnailSize.height))
        // ベースビュー
        baseView = BaseView(frame: CGRect(x: 0, y: DeviceConst.statusBarHeight, width: frame.size.width, height: frame.size.height - AppConst.thumbnailSize.height - DeviceConst.statusBarHeight))
        super.init(frame: frame)

        baseView.delegate = self
        headerView.delegate = self
        
        addSubview(baseView)
        addSubview(headerView)
        addSubview(footerView)
        
        /* テストコード */
        do {
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 20, y: 100), size: CGSize(width: 150, height: 50)))
            button.backgroundColor = UIColor.gray
            button.setTitle("フォーム情報保存", for: .normal)
            _ = button.reactive.tap
                .observe { _ in
                    NotificationCenter.default.post(name: .baseViewModelWillRegisterAsForm, object: nil)
            }
            addSubview(button)
        }
        
        do {
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 220, y: 100), size: CGSize(width: 150, height: 50)))
            button.backgroundColor = UIColor.gray
            button.setTitle("自動スクロール", for: .normal)
            _ = button.reactive.tap
                .observe { _ in
                    NotificationCenter.default.post(name: .baseViewModelWillAutoScroll, object: nil)
            }
            addSubview(button)
        }
        
        do {
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 20, y: 180), size: CGSize(width: 150, height: 50)))
            button.backgroundColor = UIColor.gray
            button.setTitle("戻る(wv)", for: .normal)
            _ = button.reactive.tap
                .observe { [weak self] _ in
            }
            addSubview(button)
        }
        
        do {
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 220, y: 180), size: CGSize(width: 150, height: 50)))
            button.backgroundColor = UIColor.gray
            button.setTitle("進む(wv)", for: .normal)
            _ = button.reactive.tap
                .observe { [weak self] _ in
            }
            addSubview(button)
        }
        
        do {
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 20, y: 260), size: CGSize(width: 150, height: 50)))
            button.backgroundColor = UIColor.gray
            button.setTitle("リロード", for: .normal)
            // TODO: リロードは自前で管理しているURLから実施する
            _ = button.reactive.tap
                .observe { _ in
                    NotificationCenter.default.post(name: .baseViewModelWillReloadWebView, object: nil)
            }
            addSubview(button)
        }

        do {
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 20, y: 340), size: CGSize(width: 150, height: 50)))
            button.backgroundColor = UIColor.gray
            button.setTitle("wv作成・移動", for: .normal)
            // TODO: リロードは自前で管理しているURLから実施する
            _ = button.reactive.tap
                .observe { [weak self] _ in
                    NotificationCenter.default.post(name: .baseViewModelWillAddWebView, object: nil)
            }
            addSubview(button)
        }
        
        do {
            let button = UIButton(frame: CGRect(origin: CGPoint(x: 220, y: 340), size: CGSize(width: 150, height: 50)))
            button.backgroundColor = UIColor.gray
            button.setTitle("現在のwv削除", for: .normal)
            _ = button.reactive.tap
                .observe { [weak self] _ in
            }
            addSubview(button)
        }
        /*-----------*/
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// MARK: Private Method
    
    private func resizeHeaderToMax() {
        headerView.resizeToMax()
        baseView.frame.origin.y = headerView.heightMax
    }
    
    private func resizeHeaderToMin() {
        headerView.resizeToMin()
        baseView.frame.origin.y = DeviceConst.statusBarHeight
    }
    
    private func slide(val: CGFloat) {
        if !isTouchEndAnimating {
            headerView.slide(value: val)
            baseView.slide(value: val)
        }
    }
    
// MARK: Public Method
    func validateUserInteraction() {
        baseView.validateUserInteraction()
    }
    
// MARK: HeaderView Delegate
    
    func headerViewDidBeginEditing() {
        baseView.isDisplayedKeyBoard = true // キーボード表示中フラグをtrueにし、自動入力させない
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
    
    func headerViewDidEndEditing() {
        overlay!.removeFromSuperview()
        overlay = nil
        headerView.finishEditing(force: false)
    }
    
// MARK: BaseView Delegate
    
    func baseViewDidEdgeSwiped(direction: EdgeSwipeDirection) {
        delegate?.baseLayerDidInvalidate(direction: direction)
    }
    
    func baseViewDidTouchEnd() {
        if headerView.isMoving {
            isTouchEndAnimating = true
            if headerView.frame.origin.y > headerViewOriginY.min / 2 {
                UIView.animate(withDuration: 0.2, animations: { 
                    self.resizeHeaderToMax()
                }, completion: { (finished) in
                    if finished {
                        self.isTouchEndAnimating = false
                    }
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.resizeHeaderToMin()
                }, completion: { (finished) in
                    if finished {
                        self.isTouchEndAnimating = false
                    }
                })
            }
        }
    }
    
    func baseViewDidScroll(speed: CGFloat) {
        if speed > 0 {
            if headerView.frame.origin.y != headerViewOriginY.max {
                if headerView.frame.origin.y + speed > headerViewOriginY.max {
                    resizeHeaderToMax()
                } else {
                    slide(val: speed)
                }
            }
        } else if speed < 0 {
            if headerView.frame.origin.y != headerViewOriginY.min {
                if headerView.frame.origin.y + speed < headerViewOriginY.min {
                    resizeHeaderToMin()
                } else {
                    slide(val: speed)
                }
            }
        }
    }
}
