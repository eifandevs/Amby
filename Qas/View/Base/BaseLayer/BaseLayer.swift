//
//  BaseLayer.swift
//  Eiger
//
//  Created by tenma on 2017/03/02.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import NSObject_Rx
import RxCocoa
import RxSwift
import UIKit

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
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_UIKeyboardDidShow")
                guard let `self` = self else { return }
                if !self.isHeaderViewEditing {
                    // 自動入力オペ要求
                    self.viewModel.changeOperationDataModel(operation: .autoFill)
                }
                log.eventOut(chain: "rx_UIKeyboardDidShow")
            }
            .disposed(by: rx.disposeBag)

        // フォアグラウンド時にベースビューの位置をMinにする
        NotificationCenter.default.rx.notification(.UIApplicationWillEnterForeground, object: nil)
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_UIApplicationWillEnterForeground")
                guard let `self` = self else { return }
                self.baseView.slideToMax()
                log.eventOut(chain: "rx_UIApplicationWillEnterForeground")
            }
            .disposed(by: rx.disposeBag)

        // BaseViewスワイプ監視
        baseView.rx_baseViewDidEdgeSwiped
            .subscribe { [weak self] object in
                log.eventIn(chain: "rx_baseViewDidEdgeSwiped")
                guard let `self` = self else { return }
                if let swipeDirection = object.element {
                    // 検索中の場合は、検索画面を閉じる
                    if self.searchMenuTableView != nil {
                        log.debug("close search menu.")
                        self.endEditing()
                        self.validateUserInteraction()
                    } else {
                        self.rx_baseLayerDidInvalidate.onNext(swipeDirection)
                    }
                }
                log.eventOut(chain: "rx_baseViewDidEdgeSwiped")
            }
            .disposed(by: rx.disposeBag)

        // BaseViewスライド監視
        baseView.rx_baseViewDidSlide
            .subscribe { [weak self] object in
                // ログが大量に出るので、コメントアウト
//                log.eventIn(chain: "rx_baseViewDidSlide")
                guard let `self` = self else { return }
                if let speed = object.element {
                    self.headerView.slide(value: speed)
                }
//                log.eventOut(chain: "rx_baseViewDidSlide")
            }
            .disposed(by: rx.disposeBag)

        // BaseViewスライドMax監視
        baseView.rx_baseViewDidSlideToMax
            .subscribe { [weak self] _ in
                // ログが大量に出るので、コメントアウト
//                log.eventIn(chain: "rx_baseViewDidSlideToMax")
                guard let `self` = self else { return }
                self.headerView.slideToMax()
//                log.eventOut(chain: "rx_baseViewDidSlideToMax")
            }
            .disposed(by: rx.disposeBag)

        // BaseViewスライドMin監視
        baseView.rx_baseViewDidSlideToMin
            .subscribe { [weak self] _ in
                // ログが大量に出るので、コメントアウト
//                log.eventIn(chain: "rx_baseViewDidSlideToMin")
                guard let `self` = self else { return }
                self.headerView.slideToMin()
//                log.eventOut(chain: "rx_baseViewDidSlideToMin")
            }
            .disposed(by: rx.disposeBag)

        // HeaderView編集開始監視
        headerView.rx_headerViewDidBeginEditing
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_headerViewDidBeginEditing")
                guard let `self` = self else { return }
                // 履歴検索を行うので、事前に永続化しておく
                CommonHistoryDataModel.s.store()
                PageHistoryDataModel.s.store()

                self.isHeaderViewEditing = true
                self.searchMenuTableView = SearchMenuTableView(frame: CGRect(origin: CGPoint(x: 0, y: self.headerView.frame.size.height), size: CGSize(width: frame.size.width, height: frame.size.height - self.headerView.frame.size.height)))
                // サーチメニュー編集終了監視
                self.searchMenuTableView!.rx_searchMenuDidEndEditing
                    .subscribe { [weak self] _ in
                        log.eventIn(chain: "rx_searchMenuDidEndEditing")
                        guard let `self` = self else { return }
                        self.headerView.closeKeyBoard()
                        log.eventOut(chain: "rx_searchMenuDidEndEditing")
                    }
                    .disposed(by: self.rx.disposeBag)

                // サーチメニュークローズ監視
                self.searchMenuTableView!.rx_searchMenuDidClose
                    .subscribe { [weak self] _ in
                        log.eventIn(chain: "rx_searchMenuDidClose")
                        guard let `self` = self else { return }
                        self.endEditing()
                        log.eventOut(chain: "rx_searchMenuDidClose")
                    }
                    .disposed(by: self.rx.disposeBag)

                self.addSubview(self.searchMenuTableView!)
                log.eventOut(chain: "rx_headerViewDidBeginEditing")
            }
            .disposed(by: rx.disposeBag)

        // HeaderView編集終了監視
        headerView.rx_headerViewDidEndEditing
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_headerViewDidEndEditing")
                guard let `self` = self else { return }
                EGApplication.sharedMyApplication.egDelegate = self.baseView
                self.isHeaderViewEditing = false
                self.searchMenuTableView!.removeFromSuperview()
                self.searchMenuTableView = nil
                log.eventOut(chain: "rx_headerViewDidEndEditing")
            }
            .disposed(by: rx.disposeBag)

        addSubview(baseView)
        addSubview(headerView)
        addSubview(footerView)
    }

    required init?(coder _: NSCoder) {
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

    /// 解放処理
    func mRelease() {
        baseView.removeFromSuperview()
        headerView.removeFromSuperview()
        footerView.removeFromSuperview()
    }

    // MARK: Private Method

    /// 編集モード終了
    private func endEditing() {
        EGApplication.sharedMyApplication.egDelegate = baseView
        isHeaderViewEditing = false
        searchMenuTableView!.removeFromSuperview()
        searchMenuTableView = nil
        headerView.finishEditing(headerFieldUpdate: false)
    }
}

// MARK: EGApplication Delegate

extension BaseLayer: EGApplicationDelegate {

    // MARK: Screen Event

    func screenTouchBegan(touch _: UITouch) {
    }

    func screenTouchEnded(touch _: UITouch) {
    }

    func screenTouchMoved(touch _: UITouch) {
    }

    func screenTouchCancelled(touch _: UITouch) {
    }
}
