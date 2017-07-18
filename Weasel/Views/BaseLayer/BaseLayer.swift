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
    let baseViewOriginY: (max: CGFloat, min: CGFloat) = (AppConst.headerViewHeight, DeviceConst.statusBarHeight)
    private var headerView: HeaderView
    private let footerView: FooterView
    private let baseView: BaseView
    private var overlay: UIButton? = nil
    private var isTouchEndAnimating = false

    override init(frame: CGRect) {
        // ヘッダービュー
        headerView = HeaderView(frame: CGRect(x: 0, y: headerViewOriginY.max, width: frame.size.width, height: AppConst.headerViewHeight))
        // フッタービュー
        footerView = FooterView(frame: CGRect(x: 0, y: DeviceConst.displaySize.height - AppConst.thumbnailSize.height, width: frame.size.width, height: AppConst.thumbnailSize.height))
        // ベースビュー
        baseView = BaseView(frame: CGRect(x: 0, y: baseViewOriginY.max, width: frame.size.width, height: frame.size.height - AppConst.thumbnailSize.height - DeviceConst.statusBarHeight))
        super.init(frame: frame)

        // フォアグラウンド時にヘッダービューの位置をMaxにする
        NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: nil) { [weak self] (notification) in
            self!.headerView.slideToMax()
        }
        
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
    private func slideHeaderView(val: CGFloat) {
        if !isTouchEndAnimating {
            headerView.slide(value: val)
        }
    }
    
    private func slideBaseView(val: CGFloat) {
        if !isTouchEndAnimating {
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
    
    func baseViewDidChangeFront() {
        headerView.slideToMax()
    }
    
    func baseViewDidTouchBegan() {
        //
    }
    
    func baseViewDidTouchEnd() {
        // タッチ終了時にヘッダービューの高さを調整する
        if headerView.isMoving {
            isTouchEndAnimating = true
            if headerView.frame.origin.y > headerViewOriginY.min / 2 {
                UIView.animate(withDuration: 0.2, animations: {
                    self.headerView.slideToMax()
                }, completion: { (finished) in
                    if finished {
                        self.isTouchEndAnimating = false
                    }
                })
            } else {
                // ベースビューの黒背景が表示される場合は、ベースビューもslideToMinする
                if !self.baseView.isLocateMin {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.headerView.slideToMin()
                        self.baseView.slideToMin()
                    }, completion: { (finished) in
                        if finished {
                            self.isTouchEndAnimating = false
                        }
                    })
                } else {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.headerView.slideToMin()
                    }, completion: { (finished) in
                        if finished {
                            self.isTouchEndAnimating = false
                        }
                    })
                }
            }
        }
    }
    
    func baseViewDidScroll(speed: CGFloat) {
        if speed > 0 {
            // 逆順方向(過去)のスクロール
            // ヘッダービューがスライド可能の場合にスライドさせる
            if !headerView.isLocateMax {
                if headerView.frame.origin.y + speed > headerViewOriginY.max {
                    // スライドした結果、Maxを超える場合は、調整する
                    headerView.slideToMax()
                } else {
                    slideHeaderView(val: speed)
                }
            }
            // ベースビューがスクロール不可の場合にスライドさせる
            if !baseView.isLocateMax && !baseView.canPastScroll {
                if baseView.frame.origin.y + speed > baseViewOriginY.max {
                    // スライドした結果、Maxを超える場合は、調整する
                    baseView.slideToMax()
                } else {
                    slideBaseView(val: speed)
                }
            }
        } else if speed < 0 {
            // 順方向(未来)のスクロール
            // ヘッダービューがスライド可能の場合にスライドさせる
            if !headerView.isLocateMin {
                if headerView.frame.origin.y + speed < headerViewOriginY.min {
                    // スライドした結果、Minを下回る場合は、調整する
                    headerView.slideToMin()
                } else {
                    slideHeaderView(val: speed)
                }
            }
            // ベースビューがスライド可能な場合にスライドさせる
            if !baseView.isLocateMin {
                if baseView.frame.origin.y + speed < baseViewOriginY.min {
                    // スライドした結果、Minを下回る場合は、調整する
                    baseView.slideToMin()
                } else {
                    slideBaseView(val: speed)
                }
            }
        }
    }
}
