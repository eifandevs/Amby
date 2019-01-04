//
//  FrontLayer.swift
//  Eiger
//
//  Created by User on 2017/06/06.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import CoreLocation
import Foundation
import RxCocoa
import RxSwift
import UIKit
import Model

enum FrontLayerAction {
    case invalidate
}

class FrontLayer: UIView {
    // アクション通知用RX
    let rx_action = PublishSubject<FrontLayerAction>()

    private let viewModel = FrontLayerViewModel()
    private var swipeDirection: EdgeSwipeDirection!
    private var optionMenu: OptionMenuTableView?
    private var overlay: UIButton!
    private var circleMenu: CircleMenu!

    private let circleButtonRadius = 43

    convenience init(frame: CGRect, swipeDirection: EdgeSwipeDirection) {
        self.init(frame: frame)
        // スワイプ方向の保持
        self.swipeDirection = swipeDirection

        // サークルメニューの作成
        let pt = CGPoint(x: -100, y: -100)
        let size = CGSize(width: circleButtonRadius, height: circleButtonRadius)
        circleMenu = CircleMenu(frame: CGRect(origin: pt, size: size), swipeDirection: swipeDirection)

        setupRx()
        addSubview(circleMenu)
    }

    /// setup rx
    private func setupRx() {
        // サークルメニュー監視
        circleMenu.rx_action
            .filter { action in
                switch action {
                case .select, .close: return true
                default: return false
                }
            }
            .subscribe { [weak self] action in
                log.eventIn("CircleMenu.rx_action")
                guard let `self` = self, let action = action.element else { return }
                switch action {
                case let .select(operation, point): self.select(operation: operation, point: point)
                case .close: self.closeWithCircleMenu()
                default: break
                }
                log.eventOut("CircleMenu.rx_action")
            }
            .disposed(by: rx.disposeBag)
        
        // サークルメニューアクティブ監視
        circleMenu.rx_action
            .filter { action in
                if case .active = action {
                    return true
                } else {
                    return false
                }
            }
            .observeOn(MainScheduler.asyncInstance) // アニメーションさせるのでメインスレッドで実行
            .subscribe { [weak self] _ in
                log.eventIn("CircleMenu.rx_action")
                guard let `self` = self else { return }
                self.active()
                log.eventOut("CircleMenu.rx_action")
            }
            .disposed(by: rx.disposeBag)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 解放処理
    func mRelease() {
        // マニュアルで解放しないと何故かdeinitが呼ばれない
        if optionMenu != nil {
            optionMenu!.removeFromSuperview()
            optionMenu = nil
        }

        if overlay != nil {
            overlay!.removeFromSuperview()
            overlay = nil
        }

        if circleMenu != nil {
            circleMenu!.removeFromSuperview()
            circleMenu = nil
        }
    }

    deinit {
        log.debug("deinit called.")
    }

    // MARK: Private Method

    private func select(operation: UserOperation, point: CGPoint) {
        switch operation {
        case .menu:
            let initialPt = point
            // オプションメニューの表示位置を計算
            let ptX = self.swipeDirection == .left ? initialPt.x / 6 : AppConst.DEVICE.DISPLAY_SIZE.width - 250 - (AppConst.DEVICE.DISPLAY_SIZE.width - initialPt.x) / 6
            let ptY: CGFloat = { () -> CGFloat in
                let y = initialPt.y - AppConst.FRONT_LAYER.OPTION_MENU_SIZE.height / 2
                if y < 0 {
                    return 0
                }
                if y + AppConst.FRONT_LAYER.OPTION_MENU_SIZE.height > AppConst.DEVICE.DISPLAY_SIZE.height {
                    return AppConst.DEVICE.DISPLAY_SIZE.height - AppConst.FRONT_LAYER.OPTION_MENU_SIZE.height
                }
                return y
            }()
            // オプションメニューを表示
            let width = AppConst.FRONT_LAYER.OPTION_MENU_SIZE.width
            let height = AppConst.FRONT_LAYER.OPTION_MENU_SIZE.height
            let optionMenuRect = CGRect(x: ptX, y: ptY, width: width, height: height)
            self.optionMenu = OptionMenuTableView(frame: optionMenuRect, swipeDirection: swipeDirection)
            // クローズ監視
            self.optionMenu!.rx_action
                .subscribe { [weak self] action in
                    log.eventIn("OptionMenuTableView.rx_action")
                    guard let `self` = self, let action = action.element, case .close = action else { return }
                    self.closeWithOptionMenu()
                    log.eventOut("OptionMenuTableView.rx_action")
                }
                .disposed(by: self.rx.disposeBag)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.addSubview(self.optionMenu!)
            }
        case .close:
            self.viewModel.close()
        case .closeAll:
            self.viewModel.closeAll()
        case .historyBack:
            self.viewModel.historyBack()
        case .copy:
            self.viewModel.copy()
        case .search:
            self.viewModel.beginSearching()
        case .add:
            self.viewModel.add()
        case .scrollUp:
            self.viewModel.scrollUp()
        case .autoScroll:
            self.viewModel.autoScroll()
        case .historyForward:
            self.viewModel.historyForward()
        case .form:
            self.viewModel.registerForm()
        case .favorite:
            self.viewModel.updateFavorite()
        case .grep:
            self.viewModel.beginGreping()
        default:
            break
        }
    }
    
    private func active() {
        // オーバーレイの作成
        self.overlay = UIButton(frame: frame)
        self.overlay.backgroundColor = UIColor.darkGray
        self.overlay.alpha = 0
        
        // ボタンタップ
        self.overlay.rx.tap
            .subscribe(onNext: { [weak self] in
                log.eventIn(chain: "rx_tap")
                guard let `self` = self else { return }
                self.closeWithOptionMenu()
                log.eventOut(chain: "rx_tap")
            })
            .disposed(by: self.rx.disposeBag)
        
        self.addSubview(self.overlay)
        // addSubviewした段階だと、サークルメニューより前面に配置されているので、最背面に移動する
        self.sendSubview(toBack: self.overlay)
        UIView.animate(withDuration: 0.35) {
            self.overlay.alpha = 0.2
        }
    }
    
    private func closeWithCircleMenu() {
        if self.optionMenu == nil {
            if let overlay = self.overlay {
                UIView.animate(withDuration: 0.15, animations: {
                    // ここでおちる
                    overlay.alpha = 0
                }, completion: { finished in
                    if finished {
                        self.rx_action.onNext(.invalidate)
                    }
                })
            } else {
                self.rx_action.onNext(.invalidate)
            }
        }
    }
    
    private func closeWithOptionMenu() {
        circleMenu.invalidate()
        UIView.animate(withDuration: 0.15, animations: {
            self.overlay.alpha = 0
            self.optionMenu?.alpha = 0
            self.alpha = 0
        }, completion: { finished in
            if finished {
                self.optionMenu?.removeFromSuperview()
                self.optionMenu = nil
                self.rx_action.onNext(.invalidate)
            }
        })
    }
}
