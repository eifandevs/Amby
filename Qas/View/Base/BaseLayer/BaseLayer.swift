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

/// ヘッダーとボディとフッターの管理
/// BaseViewからの通知をHeaderViewに伝える
class BaseLayer: UIView {
    /// 無効化通知用RX
    let rx_baseLayerDidInvalidate = PublishSubject<EdgeSwipeDirection>()
    
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

        // BaseViewスワイプ監視
        baseView.rx_baseViewDidEdgeSwiped.subscribe { [weak self] object in
            guard let `self` = self else { return }
            if let swipeDirection = object.element {
                log.debug("[BaseLayer Event]: baseViewDidEdgeSwiped")
                // 検索中の場合は、検索画面を閉じる
                if self.searchMenuTableView != nil {
                    log.debug("close search menu.")
                    self.headerViewDidEndEditing(headerFieldUpdate: false)
                    self.validateUserInteraction()
                } else {
                    self.rx_baseLayerDidInvalidate.onNext(swipeDirection)
                }
            }
        }
        .disposed(by: rx.disposeBag)
        
        // BaseViewスライド監視
        baseView.rx_baseViewDidSlide
            .subscribe { [weak self] object in
                guard let `self` = self else { return }
                if let speed = object.element {
                    self.headerView.slide(value: speed)
                }
        }
        .disposed(by: rx.disposeBag)

        // BaseViewスライドMax監視
        baseView.rx_baseViewDidSlideToMax
            .subscribe { [weak self] _ in
                guard let `self` = self else { return }
                self.headerView.slideToMax()
            }
            .disposed(by: rx.disposeBag)
        
        // BaseViewスライドMin監視
        baseView.rx_baseViewDidSlideToMin
            .subscribe { [weak self] _ in
                guard let `self` = self else { return }
                self.headerView.slideToMin()
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
        // TODO: 循環を修正する
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
