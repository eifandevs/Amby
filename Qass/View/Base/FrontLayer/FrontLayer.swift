//
//  FrontLayer.swift
//  Eiger
//
//  Created by User on 2017/06/06.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import CoreLocation
import Foundation
import NSObject_Rx
import RxCocoa
import RxSwift
import UIKit

class FrontLayer: UIView {
    // 無効化通知用RX
    let rx_frontLayerDidInvalidate = PublishSubject<()>()

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

        // Monitor menu press
        circleMenu.rx_circleMenuDidSelect
            .subscribe { [weak self] object in
                guard let `self` = self, let element = object.element else { return }
                switch element.operation {
                case .menu:
                    let initialPt = element.point
                    // オプションメニューの表示位置を計算
                    let ptX = self.swipeDirection == .left ? initialPt.x / 6 : DeviceConst.DISPLAY_SIZE.width - 250 - (DeviceConst.DISPLAY_SIZE.width - initialPt.x) / 6
                    let ptY: CGFloat = { () -> CGFloat in
                        let y = initialPt.y - AppConst.FRONT_LAYER_OPTION_MENU_SIZE.height / 2
                        if y < 0 {
                            return 0
                        }
                        if y + AppConst.FRONT_LAYER_OPTION_MENU_SIZE.height > DeviceConst.DISPLAY_SIZE.height {
                            return DeviceConst.DISPLAY_SIZE.height - AppConst.FRONT_LAYER_OPTION_MENU_SIZE.height
                        }
                        return y
                    }()
                    // オプションメニューを表示
                    let width = AppConst.FRONT_LAYER_OPTION_MENU_SIZE.width
                    let height = AppConst.FRONT_LAYER_OPTION_MENU_SIZE.height
                    let optionMenuRect = CGRect(x: ptX, y: ptY, width: width, height: height)
                    self.optionMenu = OptionMenuTableView(frame: optionMenuRect, swipeDirection: swipeDirection)
                    // クローズ監視
                    self.optionMenu?.rx_optionMenuTableViewDidClose
                        .subscribe({ [weak self] _ in
                            log.eventIn(chain: "rx_optionMenuTableViewDidClose")
                            guard let `self` = self else { return }
                            self.close()
                            log.eventOut(chain: "rx_optionMenuTableViewDidClose")
                        })
                        .disposed(by: self.rx.disposeBag)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.addSubview(self.optionMenu!)
                    }
                case .close:
                    self.viewModel.removePageHistoryDataModel()
                case .historyBack:
                    self.viewModel.goBackCommonHistoryDataModel()
                case .copy:
                    self.viewModel.copyPageHistoryDataModel()
                case .search:
                    self.viewModel.beginEditingHeaderViewDataModel()
                case .add:
                    self.viewModel.insertPageHistoryDataModel()
                case .scrollUp:
                    self.viewModel.executeOperationDataModel(operation: .scrollUp)
                case .autoScroll:
                    self.viewModel.executeOperationDataModel(operation: .autoScroll)
                case .historyForward:
                    self.viewModel.goForwardCommonHistoryDataModel()
                case .form:
                    self.viewModel.executeOperationDataModel(operation: .form)
                case .favorite:
                    self.viewModel.registerFavoriteDataModel()
                case .grep:
                    self.viewModel.beginGrepingHeaderViewDataModel()
                default:
                    break
                }
            }
            .disposed(by: rx.disposeBag)

        // 有効化監視
        circleMenu.rx_circleMenuDidActive
            .observeOn(MainScheduler.asyncInstance) // アニメーションさせるのでメインスレッドで実行
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_circleMenuDidActive")
                guard let `self` = self else { return }
                // オーバーレイの作成
                self.overlay = UIButton(frame: frame)
                self.overlay.backgroundColor = UIColor.darkGray
                self.overlay.alpha = 0

                // ボタンタップ
                self.overlay.rx.tap
                    .subscribe(onNext: { [weak self] in
                        log.eventIn(chain: "rx_tap")
                        guard let `self` = self else { return }
                        self.close()
                        log.eventOut(chain: "rx_tap")
                    })
                    .disposed(by: self.rx.disposeBag)

                self.addSubview(self.overlay)
                // addSubviewした段階だと、サークルメニューより前面に配置されているので、最背面に移動する
                self.sendSubview(toBack: self.overlay)
                UIView.animate(withDuration: 0.35) {
                    self.overlay.alpha = 0.2
                }
                log.eventOut(chain: "rx_circleMenuDidActive")
            }
            .disposed(by: rx.disposeBag)

        // クローズ監視
        circleMenu.rx_circleMenuDidClose
            .observeOn(MainScheduler.asyncInstance) // アニメーションさせるのでメインスレッドで実行
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_circleMenuDidClose")
                guard let `self` = self else { return }
                if self.optionMenu == nil {
                    if let overlay = self.overlay {
                        UIView.animate(withDuration: 0.15, animations: {
                            // ここでおちる
                            overlay.alpha = 0
                        }, completion: { finished in
                            if finished {
                                self.rx_frontLayerDidInvalidate.onNext(())
                            }
                        })
                    } else {
                        self.rx_frontLayerDidInvalidate.onNext(())
                    }
                }
                log.eventOut(chain: "rx_circleMenuDidClose")
            }
            .disposed(by: rx.disposeBag)

        addSubview(circleMenu)
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

    private func close() {
        circleMenu.invalidate()
        UIView.animate(withDuration: 0.15, animations: {
            self.overlay.alpha = 0
            self.optionMenu?.alpha = 0
            self.alpha = 0
        }, completion: { finished in
            if finished {
                self.optionMenu?.removeFromSuperview()
                self.optionMenu = nil
                self.rx_frontLayerDidInvalidate.onNext(())
            }
        })
    }
}
