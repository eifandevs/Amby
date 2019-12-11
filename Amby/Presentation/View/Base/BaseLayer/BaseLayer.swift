//
//  BaseLayer.swift
//  Eiger
//
//  Created by tenma on 2017/03/02.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

enum BaseLayerAction {
    case invalidate(swipeDirection: EdgeSwipeDirection)
}

/// ヘッダーとボディとフッターの管理
/// BaseViewからの通知をHeaderViewに伝える
class BaseLayer: UIView {
    /// アクション通知用RX
    let rx_action = PublishSubject<BaseLayerAction>()

    let viewModel = BaseLayerViewModel()
    let headerViewOriginY: (max: CGFloat, min: CGFloat) = (0, -(AppConst.BASE_LAYER.HEADER_HEIGHT - AppConst.DEVICE.STATUS_BAR_HEIGHT))
    let baseViewOriginY: (max: CGFloat, min: CGFloat) = (AppConst.BASE_LAYER.HEADER_HEIGHT, AppConst.DEVICE.STATUS_BAR_HEIGHT)
    private var headerView: HeaderView
    private let footerView: FooterView
    private let baseView: BaseView
    private var searchMenuTableView: SearchMenuTableView? // 検索ビュー
    private var grepOverlay: UIButton? // グレップ中のオーバーレイ
    private var grepOperationView: GrepOperationView? // グレップ中の操作ビュー

    struct BaseLayerState: OptionSet {
        let rawValue: Int
        /// 検索中フラグ
        static let isHeaderViewEditing = BaseLayerState(rawValue: 1 << 0)
        /// グレップ中フラグ
        static let isHeaderViewGreping = BaseLayerState(rawValue: 1 << 1)
    }

    private var state: BaseLayerState = []

    override init(frame: CGRect) {
        // ヘッダービュー
        headerView = HeaderView(frame: CGRect(x: 0, y: headerViewOriginY.max, width: AppConst.DEVICE.DISPLAY_SIZE.width, height: AppConst.BASE_LAYER.HEADER_HEIGHT))
        // フッタービュー
        footerView = FooterView(frame: CGRect(x: 0, y: AppConst.DEVICE.DISPLAY_SIZE.height - AppConst.BASE_LAYER.FOOTER_HEIGHT, width: AppConst.DEVICE.DISPLAY_SIZE.width, height: AppConst.BASE_LAYER.FOOTER_HEIGHT))
        // ベースビュー
        baseView = BaseView(frame: CGRect(x: 0, y: baseViewOriginY.max, width: AppConst.DEVICE.DISPLAY_SIZE.width, height: AppConst.BASE_LAYER.BASE_HEIGHT))
        super.init(frame: frame)

        addSubview(baseView)
        addSubview(headerView)
        addSubview(footerView)

        setupRx(frame: frame)

        viewModel.rebuild()
    }

    /// setup rx
    private func setupRx(frame: CGRect) {
        // キーボード監視
        // キーボード表示の処理(フォームの自動設定)
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardDidShow, object: nil)
            .subscribe { [weak self] _ in
                guard let `self` = self else { return }
                if !self.state.contains(.isHeaderViewEditing) && self.viewModel.canAutoFill {
                    // 自動入力オペ要求
                    self.viewModel.autoFill()
                } else {
                    log.warning("cannot autofill")
                }
            }
            .disposed(by: rx.disposeBag)

        // フォアグラウンド時にベースビューの位置をMinにする
        NotificationCenter.default.rx.notification(.UIApplicationWillEnterForeground, object: nil)
            .subscribe { [weak self] _ in
                guard let `self` = self else { return }
                self.baseView.slideToMax()
            }
            .disposed(by: rx.disposeBag)

        // グレップ完了監視
        viewModel.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }
                log.eventIn(chain: "BaseViewModel.rx_action. action: \(action)")
                switch action {
                case .finishGrep:
                    if let grepOverlay = self.grepOverlay {
                        self.grepOperationView = GrepOperationView(frame: CGRect(x: 30, y: 200, width: 90, height: 170))
                        self.grepOperationView!.upButton.rx.tap
                            .subscribe(onNext: { [weak self] in
                                guard let `self` = self else { return }
                                self.viewModel.grepPrevious()
                            })
                            .disposed(by: self.rx.disposeBag)
                        self.grepOperationView!.downButton.rx.tap
                            .subscribe(onNext: { [weak self] in
                                guard let `self` = self else { return }
                                self.viewModel.grepNext()
                            })
                            .disposed(by: self.rx.disposeBag)
                        grepOverlay.addSubview(self.grepOperationView!)
                    }
                    log.debug("add grep operation view.")
                }
            }
            .disposed(by: rx.disposeBag)

        // BaseViewアクション監視
        baseView.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }
                log.eventIn(chain: "BaseView.rx_action. action: \(action)")
                switch action {
                case let .swipe(direction):
                    // 検索中の場合は、検索画面を閉じる
                    if self.searchMenuTableView != nil {
                        log.debug("close search menu.")
                        self.endEditingWithHeader()
                        self.validateUserInteraction()
                    } else {
                        self.rx_action.onNext(.invalidate(swipeDirection: direction))
                    }
                case let .slide(distance):
                    self.headerView.slide(value: distance)
                case .slideToMax: self.headerView.slideToMax()
                case .slideToMin: self.headerView.slideToMin()
                default: break
                }
                log.eventOut(chain: "BaseView.rx_action. action: \(action)")
            }
            .disposed(by: rx.disposeBag)

        // HeaderViewアクション監視
        headerView.rx_action
            .subscribe { [weak self] action in
                log.eventIn(chain: "HeaderView.rx_action")
                guard let `self` = self, let action = action.element else { return }

                switch action {
                case .beginSearching: self.beginSearching(frame: frame)
                case .endEditing:
                    // ヘッダーのクローズボタン押下 or 検索開始
                    // ヘッダーフィールドやヘッダービューはすでにクローズ処理を実施しているので、サーチメニューの削除をする
                    self.endEditing()
                case .beginGreping: self.beginGreping(frame: frame)
                case .endGreping:
                    // ヘッダーのクローズボタン押下 or 検索開始
                    // ヘッダーフィールドやヘッダービューはすでにクローズ処理を実施しているので、サーチメニューの削除をする
                    self.endGreping()
                }
                log.eventOut(chain: "HeaderView.rx_action")
            }
            .disposed(by: rx.disposeBag)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log.debug("deinit called.")
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

    /// 検索開始
    private func beginSearching(frame: CGRect) {
        guard baseView.isBuilt else { return }

        baseView.slideToMax()

        state.insert(.isHeaderViewEditing)
        searchMenuTableView = SearchMenuTableView(frame: CGRect(origin: CGPoint(x: 0, y: headerView.frame.size.height), size: CGSize(width: frame.size.width, height: frame.size.height - headerView.frame.size.height)))
        // サーチメニューアクション監視
        searchMenuTableView!.rx_action
            .subscribe { [weak self] action in
                log.eventIn(chain: "SearchMenuTableView.rx_action")
                guard let `self` = self, let action = action.element else { return }

                switch action {
                case .endEditing:
                    self.headerView.closeKeyBoard()
                case .close:
                    // サーチメニューのクローズ要求を受けて、ヘッダービューにクローズ要求を送り、自分はサーチメニューの削除をする
                    self.endEditingWithHeader()
                }
                log.eventOut(chain: "SearchMenuTableView.rx_action")
            }
            .disposed(by: rx.disposeBag)

        addSubview(searchMenuTableView!)
        searchMenuTableView!.getModelData()
    }

    /// 編集モード終了
    private func endEditing() {
        EGApplication.sharedMyApplication.egDelegate = baseView
        state.remove(.isHeaderViewEditing)
        searchMenuTableView!.removeFromSuperview()
        searchMenuTableView = nil
    }

    private func endEditingWithHeader() {
        endEditing()
        headerView.endEditing(headerFieldUpdate: false)
    }

    private func beginGreping(frame: CGRect) {
        baseView.slideToMax()

        state.insert(.isHeaderViewGreping)
        grepOverlay = UIButton(frame: CGRect(origin: CGPoint(x: 0, y: headerView.frame.size.height), size: CGSize(width: frame.size.width, height: frame.size.height - headerView.frame.size.height)))

        // グレップ中に画面をタップ
        grepOverlay!.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.endGrepingWithHeader()
            })
            .disposed(by: rx.disposeBag)

        addSubview(grepOverlay!)
    }

    /// グレップモード終了
    private func endGreping() {
        EGApplication.sharedMyApplication.egDelegate = baseView
        state.remove(.isHeaderViewGreping)
        grepOverlay!.removeFromSuperview()
        grepOverlay = nil
    }

    private func endGrepingWithHeader() {
        endGreping()
        headerView.endGreping()
    }
}

// MARK: EGApplication Delegate

extension BaseLayer: EGApplicationDelegate {
    // MARK: Screen Event

    func screenTouchBegan(touch _: UITouch) {}

    func screenTouchEnded(touch _: UITouch) {}

    func screenTouchMoved(touch _: UITouch) {}

    func screenTouchCancelled(touch _: UITouch) {}
}
