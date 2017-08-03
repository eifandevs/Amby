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

class BaseLayer: UIView, HeaderViewDelegate, BaseViewDelegate, SearchMenuTableViewDelegate, EGApplicationDelegate {
    
    var delegate: BaseLayerDelegate?
    let headerViewOriginY: (max: CGFloat, min: CGFloat) = (0, -(AppConst.headerViewHeight - DeviceConst.statusBarHeight))
    let baseViewOriginY: (max: CGFloat, min: CGFloat) = (AppConst.headerViewHeight, DeviceConst.statusBarHeight)
    private var headerView: HeaderView
    private let footerView: FooterView
    private let baseView: BaseView
    private var overlay: SearchMenuTableView? = nil
    private var isTouchEndAnimating = false
    private var isHeaderViewEditing = false

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
// MARK: SearchMenuTableView Delegate
    func searchMenuDidEndEditing() {
        headerView.closeKeyBoard()
    }
    
    func searchMenuDidClose() {
        headerViewDidEndEditing(headerFieldUpdate: false)
    }
    
// MARK: HeaderView Delegate
    func headerViewDidBeginEditing() {
        // 履歴検索を行うので、事前に永続化しておく
        NotificationCenter.default.post(name: .baseViewModelWillStoreHistory, object: nil)

        // ディスプレイタップのイベントをベースビューから奪う
        // サークルメニューを表示させないため
        EGApplication.sharedMyApplication.egDelegate = self
        isHeaderViewEditing = true
        overlay = SearchMenuTableView(frame: CGRect(origin: CGPoint(x: 0, y: self.headerView.frame.size.height), size: CGSize(width: frame.size.width, height: frame.size.height - self.headerView.frame.size.height)))
        overlay?.delegate = self
        addSubview(overlay!)
    }
    
    func headerViewDidEndEditing(headerFieldUpdate: Bool) {
        EGApplication.sharedMyApplication.egDelegate = baseView
        isHeaderViewEditing = false
        overlay!.removeFromSuperview()
        overlay = nil
        headerView.finishEditing(headerFieldUpdate: headerFieldUpdate)
    }

// MARK: Screen Event
    func screenTouchBegan(touch: UITouch) {
    }
    func screenTouchEnded(touch: UITouch) {
    }
    func screenTouchMoved(touch: UITouch) {
    }
    func screenTouchCancelled(touch: UITouch) {
    }
    
// MARK: BaseView Delegate
    func baseViewWillAutoInput() {
        // ベースビューから自動入力したいと通知がきたので、判断する
        if !isHeaderViewEditing {
            NotificationCenter.default.post(name: .baseViewModelWillAutoInput, object: nil)
        }
    }
    
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
        // タッチ終了時にヘッダービューとベースビューの高さを調整する
        if headerView.isMoving {
            isTouchEndAnimating = true
            if headerView.frame.origin.y > headerViewOriginY.min / 2 {
                UIView.animate(withDuration: 0.2, animations: {
                    self.headerView.slideToMax()
                    self.baseView.slideToMax()
                }, completion: { (finished) in
                    if finished {
                        self.isTouchEndAnimating = false
                    }
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.headerView.slideToMin()
                    self.baseView.slideToMin()
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
            // ベースビューがスライド可能な場合にスライドさせる
            if !baseView.isLocateMax {
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
