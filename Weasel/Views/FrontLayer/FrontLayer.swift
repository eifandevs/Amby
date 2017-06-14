//
//  FrontLayer.swift
//  Eiger
//
//  Created by User on 2017/06/06.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

protocol FrontLayerDelegate {
    func frontLayerDidInvalidate()
}

class FrontLayer: UIView, CircleMenuDelegate, OptionMenuTableViewDelegate {
    var delegate: FrontLayerDelegate?
    var swipeDirection: EdgeSwipeDirection = .none
    private var optionMenu: OptionMenuTableView? = nil
    private var detailMenu: OptionMenuTableView? = nil
    private var overlay: UIButton! = nil

    let kCircleButtonRadius = 43;
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        overlay = UIButton(frame: frame)
        _ = overlay.reactive.tap
            .observe { [weak self] _ in
                if let optionMenu = self!.optionMenu {
                    optionMenu.removeFromSuperview()
                    self!.optionMenu = nil
                    self!.delegate?.frontLayerDidInvalidate()
                }
        }
        addSubview(overlay)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        let menuItems = [
            [
                CircleMenuItem(tapAction: { [weak self] (initialPt: CGPoint) in
                    // オプションメニューの表示位置を計算
                    let ptX = self!.swipeDirection == .left ? initialPt.x / 6 : DeviceDataManager.shared.displaySize.width - 250  - (DeviceDataManager.shared.displaySize.width - initialPt.x) / 6
                    let ptY: CGFloat = { () -> CGFloat in
                        let y = initialPt.y - AppDataManager.shared.optionMenuSize.height / 2
                        if y < 0 {
                            return 0
                        }
                        if y + AppDataManager.shared.optionMenuSize.height > DeviceDataManager.shared.displaySize.height {
                            return DeviceDataManager.shared.displaySize.height - AppDataManager.shared.optionMenuSize.height
                        }
                        return y
                    }()
                    self!.optionMenu = OptionMenuTableView(frame: CGRect(x: ptX, y: ptY, width: AppDataManager.shared.optionMenuSize.width, height: AppDataManager.shared.optionMenuSize.height), viewModel: BaseMenuViewModel(), direction: self!.swipeDirection)
                    self!.optionMenu?.delegate = self
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self!.addSubview(self!.optionMenu!)
                    }
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("自動スクロール")
                    NotificationCenter.default.post(name: .baseViewModelWillAutoScroll, object: nil)
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("ヒストリーバック")
                    NotificationCenter.default.post(name: .baseViewModelWillHistoryBackWebView, object: nil)
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("ヒストリーフォワード")
                    NotificationCenter.default.post(name: .baseViewModelWillHistoryForwardWebView, object: nil)
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("デリート")
                    NotificationCenter.default.post(name: .baseViewModelWillRemoveWebView, object: nil)
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("アッド")
                    NotificationCenter.default.post(name: .baseViewModelWillAddWebView, object: nil)
                })
            ],
            [
                CircleMenuItem(tapAction: { _ in
                    log.warning("裏メニュー")
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("裏メニュー")
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("裏メニュー")
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("裏メニュー")
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("裏メニュー")
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("裏メニュー")
                })
            ]
        ]
        let circleMenu = CircleMenu(frame: CGRect(origin: CGPoint(x: -100, y: -100), size: CGSize(width: kCircleButtonRadius, height: kCircleButtonRadius)) ,menuItems: menuItems)
        circleMenu.swipeDirection = swipeDirection
        circleMenu.delegate = self
        addSubview(circleMenu)
    }
    
// MARK: CircleMenuDelegate
    func circleMenuDidClose() {
        if self.optionMenu == nil {
            delegate?.frontLayerDidInvalidate()
        }
    }
    
// MARK: OptionMenuTableViewDelegate
    func optionMenuDidClose() {
        delegate?.frontLayerDidInvalidate()
    }
}
