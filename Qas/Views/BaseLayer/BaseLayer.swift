//
//  BaseLayer.swift
//  Eiger
//
//  Created by tenma on 2017/03/02.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

protocol BaseLayerDelegate: class {
    func baseLayerDidInvalidate(direction: EdgeSwipeDirection)
}

class BaseLayer: UIView, HeaderViewDelegate, BaseViewDelegate, SearchMenuTableViewDelegate, EGApplicationDelegate {
    
    weak var delegate: BaseLayerDelegate?
    let headerViewOriginY: (max: CGFloat, min: CGFloat) = (0, -(AppConst.headerViewHeight - DeviceConst.statusBarHeight))
    let baseViewOriginY: (max: CGFloat, min: CGFloat) = (AppConst.headerViewHeight, DeviceConst.statusBarHeight)
    private var headerView: HeaderView
    private let footerView: FooterView
    private let baseView: BaseView
    private var searchMenuTableView: SearchMenuTableView? = nil
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
            guard let `self` = self else { return }
            self.headerView.slideToMax()
        }
        
        baseView.delegate = self
        headerView.delegate = self
        
        addSubview(baseView)
        addSubview(headerView)
        addSubview(footerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        log.debug("[BaseLayer Event]: searchMenuDidEndEditing. close keyboard")
        headerView.closeKeyBoard()
    }
    
    func searchMenuDidClose() {
        log.debug("[BaseLayer Event]: searchMenuDidClose")
        headerViewDidEndEditing(headerFieldUpdate: false)
    }
    
// MARK: HeaderView Delegate
    func headerViewDidBeginEditing() {
        log.debug("[BaseLayer Event]: headerViewDidBeginEditing")
        // 履歴検索を行うので、事前に永続化しておく
        NotificationCenter.default.post(name: .baseViewModelWillStoreHistory, object: nil)

        // ディスプレイタップのイベントをベースビューから奪う
        // サークルメニューを表示させないため
        EGApplication.sharedMyApplication.egDelegate = self
        isHeaderViewEditing = true
        searchMenuTableView = SearchMenuTableView(frame: CGRect(origin: CGPoint(x: 0, y: self.headerView.frame.size.height), size: CGSize(width: frame.size.width, height: frame.size.height - self.headerView.frame.size.height)))
        searchMenuTableView?.delegate = self
        addSubview(searchMenuTableView!)
    }
    
    func headerViewDidEndEditing(headerFieldUpdate: Bool) {
        log.debug("[BaseLayer Event]: headerViewDidEndEditing")
        EGApplication.sharedMyApplication.egDelegate = baseView
        isHeaderViewEditing = false
        searchMenuTableView!.removeFromSuperview()
        searchMenuTableView = nil
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
        log.debug("[BaseLayer Event]: baseViewWillAutoInput")
        // ベースビューから自動入力したいと通知がきたので、判断する
        if !isHeaderViewEditing {
            NotificationCenter.default.post(name: .baseViewModelWillAutoInput, object: nil)
        }
    }
    
    func baseViewDidEdgeSwiped(direction: EdgeSwipeDirection) {
        log.debug("[BaseLayer Event]: baseViewDidEdgeSwiped")
        delegate?.baseLayerDidInvalidate(direction: direction)
    }
    
    func baseViewDidChangeFront() {
        log.debug("[BaseLayer Event]: baseViewDidChangeFront. headerView slideToMax")
        headerView.slideToMax()
    }
    
    func baseViewDidTouchBegan() {
        //
    }
    
    func baseViewDidTouchEnd() {
        log.debug("[BaseLayer Event]: baseViewDidTouchEnd. adjust header location")
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
