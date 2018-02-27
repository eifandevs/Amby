//
//  BaseLayer.swift
//  Eiger
//
//  Created by tenma on 2017/03/02.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

protocol BaseLayerDelegate: class {
    func baseLayerDidInvalidate(direction: EdgeSwipeDirection)
}

class BaseLayer: UIView {
    weak var delegate: BaseLayerDelegate?
    let viewModel = BaseLayerViewModel()
    let headerViewOriginY: (max: CGFloat, min: CGFloat) = (0, -(AppConst.BASE_LAYER_HEADER_HEIGHT - DeviceConst.STATUS_BAR_HEIGHT))
    let baseViewOriginY: (max: CGFloat, min: CGFloat) = (AppConst.BASE_LAYER_HEADER_HEIGHT, DeviceConst.STATUS_BAR_HEIGHT)
    private var headerView: HeaderView
    private let footerView: FooterView
    private let baseView: BaseView
    private var searchMenuTableView: SearchMenuTableView?
    private var isTouchEndAnimating = false
    private var isHeaderViewEditing = false

    override init(frame: CGRect) {
        // ヘッダービュー
        headerView = HeaderView(frame: CGRect(x: 0, y: headerViewOriginY.max, width: DeviceConst.DISPLAY_SIZE.width, height: AppConst.BASE_LAYER_HEADER_HEIGHT))
        // フッタービュー
        footerView = FooterView(frame: CGRect(x: 0, y: DeviceConst.DISPLAY_SIZE.height - AppConst.BASE_LAYER_FOOTER_HEIGHT, width: DeviceConst.DISPLAY_SIZE.width, height: AppConst.BASE_LAYER_FOOTER_HEIGHT))
        // ベースビュー
        baseView = BaseView(frame: CGRect(x: 0, y: baseViewOriginY.max, width: DeviceConst.DISPLAY_SIZE.width, height: AppConst.BASE_LAYER_BASE_HEIGHT - AppConst.BASE_LAYER_HEADER_HEIGHT + DeviceConst.STATUS_BAR_HEIGHT))
        super.init(frame: frame)

        // キーボード監視
        // キーボード表示の処理(フォームの自動設定)
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardDidShow, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[BaseLayer Event]: NSNotification.Name.UIKeyboardDidShow")
                if !self.isHeaderViewEditing {
                    // 自動入力オペ要求
                    self.viewModel.changeOperationDataModel(operation: .autoInput)
                }
            }
            .disposed(by: self.rx.disposeBag)
        
        // フォアグラウンド時にヘッダービューの位置をMaxにする
        NotificationCenter.default.rx.notification(.UIApplicationWillEnterForeground, object: nil)
            .subscribe { [weak self] notification in
                guard let `self` = self else { return }
                log.debug("[BaseLayer Event]: UIApplicationWillEnterForeground")
                UIView.animate(withDuration: 0.35, animations: {
                    self.headerView.slideToMax()
                }, completion: nil)
            }
            .disposed(by: self.rx.disposeBag)

        // BaseViewスワイプ監視
        baseView.rx_baseViewDidEdgeSwiped.subscribe{ [weak self] object in
            guard let `self` = self else { return }
            if let swipeDirection = object.element {
                log.debug("[BaseLayer Event]: baseViewDidEdgeSwiped")
                // 検索中の場合は、検索画面を閉じる
                if let _ = self.searchMenuTableView {
                    log.debug("close search menu.")
                    self.headerViewDidEndEditing(headerFieldUpdate: false)
                    self.validateUserInteraction()
                } else {
                    self.delegate?.baseLayerDidInvalidate(direction: swipeDirection)
                }
            }
        }
        .disposed(by: rx.disposeBag)
        
        // BaseViewタッチ終了検知
        baseView.rx_baseViewDidTouchEnd.subscribe{ [weak self] _ in
            guard let `self` = self else { return }
            log.debug("[BaseLayer Event]: baseViewDidTouchEnd. adjust header location")
            // タッチ終了時にヘッダービューとベースビューの高さを調整する
            if self.headerView.isMoving {
                self.isTouchEndAnimating = true
                if self.headerView.frame.origin.y > self.headerViewOriginY.min / 2 {
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
        .disposed(by: rx.disposeBag)
        
        // BaseViewスクロール監視
        
        baseView.rx_baseViewDidScroll
            .map({ -$0 })
            .observeOn(MainScheduler.asyncInstance)
            .subscribe { [weak self] object in
                guard let `self` = self else { return }
                if let speed = object.element {
                    if speed > 0 {
                        // 逆順方向(過去)のスクロール
                        // ヘッダービューがスライド可能の場合にスライドさせる
                        if !self.headerView.isLocateMax {
                            if self.headerView.frame.origin.y + speed > self.headerViewOriginY.max {
                                // スライドした結果、Maxを超える場合は、調整する
                                self.headerView.slideToMax()
                            } else {
                                self.slideHeaderView(val: speed)
                            }
                        }
                        // ベースビューがスライド可能な場合にスライドさせる
                        if !self.baseView.isLocateMax {
                            if self.baseView.frame.origin.y + speed > self.baseViewOriginY.max {
                                // スライドした結果、Maxを超える場合は、調整する
                                self.baseView.slideToMax()
                            } else {
                                self.slideBaseView(val: speed)
                            }
                        }
                    } else if speed < 0 {
                        // 順方向(未来)のスクロール
                        // ヘッダービューがスライド可能の場合にスライドさせる
                        if !self.headerView.isLocateMin {
                            if self.headerView.frame.origin.y + speed < self.headerViewOriginY.min {
                                // スライドした結果、Minを下回る場合は、調整する
                                self.headerView.slideToMin()
                            } else {
                                self.slideHeaderView(val: speed)
                            }
                        }
                        // ベースビューがスライド可能な場合にスライドさせる
                        if !self.baseView.isLocateMin {
                            if self.baseView.frame.origin.y + speed < self.baseViewOriginY.min {
                                // スライドした結果、Minを下回る場合は、調整する
                                self.baseView.slideToMin()
                            } else {
                                self.slideBaseView(val: speed)
                            }
                        }
                    }
                }
        }
        .disposed(by: rx.disposeBag)

        headerView.delegate = self
        
        addSubview(baseView)
        addSubview(headerView)
        addSubview(footerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        log.debug("deinit called.")
        NotificationCenter.default.removeObserver(self)
    }
    
// MARK: Private Method
    private func slideHeaderView(val: CGFloat) {
        /// コンテンツサイズが画面より小さい場合は、過去スクロールしない
        if val < 0 && !baseView.shouldScroll {
            return
        }
        
        if !isTouchEndAnimating {
            headerView.slide(value: val)
        }
    }
    
    private func slideBaseView(val: CGFloat) {
        
        /// コンテンツサイズが画面より小さい場合は、過去スクロールしない
        if val < 0 && !baseView.shouldScroll {
            return
        }
        
        if !isTouchEndAnimating {
            baseView.slide(value: val)
        }
    }
    
// MARK: Public Method
    func validateUserInteraction() {
        baseView.validateUserInteraction()
    }
}

// MARK: EGApplication Delegate
extension BaseLayer: EGApplicationDelegate {
    // MARK: Screen Event
    func screenTouchBegan(touch: UITouch) {
    }
    func screenTouchEnded(touch: UITouch) {
    }
    func screenTouchMoved(touch: UITouch) {
    }
    func screenTouchCancelled(touch: UITouch) {
    }
}

// MARK: HeaderView Delegate
extension BaseLayer: HeaderViewDelegate {
    func headerViewDidBeginEditing() {
        log.debug("[BaseLayer Event]: headerViewDidBeginEditing")
        // 履歴検索を行うので、事前に永続化しておく
        CommonHistoryDataModel.s.store()
        PageHistoryDataModel.s.store()

        isHeaderViewEditing = true
        searchMenuTableView = SearchMenuTableView(frame: CGRect(origin: CGPoint(x: 0, y: self.headerView.frame.size.height), size: CGSize(width: frame.size.width, height: frame.size.height - self.headerView.frame.size.height)))
        searchMenuTableView?.delegate = self
        addSubview(searchMenuTableView!)
    }
    
    func headerViewDidEndEditing(headerFieldUpdate: Bool) {
        log.debug("[BaseLayer Event]: headerViewDidEndEditing headerFieldUpdate: \(headerFieldUpdate)")
        EGApplication.sharedMyApplication.egDelegate = baseView
        isHeaderViewEditing = false
        searchMenuTableView!.removeFromSuperview()
        searchMenuTableView = nil
        headerView.finishEditing(headerFieldUpdate: headerFieldUpdate)
    }
}

// MARK: SearchMenuTableView Delegate
extension BaseLayer: SearchMenuTableViewDelegate {
    func searchMenuDidEndEditing() {
        log.debug("[BaseLayer Event]: searchMenuDidEndEditing. close keyboard")
        headerView.closeKeyBoard()
    }
    
    func searchMenuDidClose() {
        log.debug("[BaseLayer Event]: searchMenuDidClose")
        headerViewDidEndEditing(headerFieldUpdate: false)
    }
}
