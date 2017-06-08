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
                CircleMenuItem(tapAction: { _ in
                    log.warning("たあっぷお")
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("たあっぷお")
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("たあっぷお")
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("たあっぷお")
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("たあっぷお")
                }),
                CircleMenuItem(tapAction: { _ in
                    log.warning("たあっぷお")
                })
            ]
        ]
        let circleMenu = CircleMenu(frame: CGRect(origin: CGPoint(x: -100, y: -100), size: CGSize(width: kCircleButtonRadius, height: kCircleButtonRadius)) ,menuItems: menuItems)
        circleMenu.delegate = self
        addSubview(circleMenu)
    }
    
// MARK: CircleMenu Delegate
    func circleMenuDidClose() {
        delegate?.frontLayerDidInvalidate()
    }
}
