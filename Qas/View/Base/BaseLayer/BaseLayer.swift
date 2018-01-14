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
        registerForKeyboardDidShowNotification { [weak self] (notification, size) in
            guard let `self` = self else { return }
            if !self.isHeaderViewEditing {
                // 自動入力オペ要求
                self.viewModel.changeOperationDataModel(operation: .autoInput)
            }
        }
        
        // フォアグラウンド時にヘッダービューの位置をMaxにする
        NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else { return }
            UIView.animate(withDuration: 0.35, animations: {
                self.headerView.slideToMax()
            }, completion: nil)
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

// MARK: BaseView Delegate
extension BaseLayer: BaseViewDelegate {
    
    func baseViewDidEdgeSwiped(direction: EdgeSwipeDirection) {
        log.debug("[BaseLayer Event]: baseViewDidEdgeSwiped")
        // 検索中の場合は、検索画面を閉じる
        if let _ = searchMenuTableView {
            log.debug("close search menu.")
            headerViewDidEndEditing(headerFieldUpdate: false)
            validateUserInteraction()
        } else {
            delegate?.baseLayerDidInvalidate(direction: direction)
        }
    }
    
    func baseViewDidChangeFront() {
        log.debug("[BaseLayer Event]: baseViewDidChangeFront. headerView slideToMax")
        // ページ切り替え時のヘッダー表示はやめる
//        if !headerView.isLocateMax {
//            UIView.animate(withDuration: 0.35, animations: {
//                self.headerView.slideToMax()
//            }, completion: nil)
//        }
    }
    
    func baseViewDidTouchBegan() {
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
