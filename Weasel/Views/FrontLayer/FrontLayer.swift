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

class FrontLayer: UIView, CircleMenuDelegate {
    var delegate: FrontLayerDelegate?
    var swipeDirection: EdgeSwipeDirection = .none
    private var optionMenu: OptionMenuTableView? = nil

    let kCircleButtonRadius = 43;
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        let menuItems = [
            [
                CircleMenuItem(tapAction: { [weak self] _ in
                    log.warning("メニュー")
                    self!.optionMenu = OptionMenuTableView(frame: CGRect(x: 0, y: 100, width: 200, height: 300))
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
    
// MARK: CircleMenu Delegate
    func circleMenuDidClose() {
        if self.optionMenu == nil {
            delegate?.frontLayerDidInvalidate()
        }
    }
}
