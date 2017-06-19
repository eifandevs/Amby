//
//  ShadowView.swift
//  Eiger
//
//  Created by temma on 2017/03/05.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

protocol ShadowView {
    func addShadow()
}

extension ShadowView where Self: UIView {
    func addShadow() {
        layer.shadowOffset = CGSize(width: 0, height: 0.5)
        layer.shadowRadius = 0.2
        layer.shadowOpacity = 0.3
        layer.masksToBounds = false
    }
    
    func addAreaShadow() {
        layer.shadowOffset = CGSize(width: 0, height: -0.5)
        layer.shadowRadius = 0.2
        layer.shadowOpacity = 0.3
        layer.masksToBounds = false
    }
    
    func addCircleShadow() {
        layer.shadowOffset = CGSize(width: 0, height: 0.65)
        layer.shadowRadius = 0.4
        layer.shadowOpacity = 0.5
        layer.masksToBounds = false
    }
    
    func addMenuShadow() {
        layer.shadowOffset = CGSize(width: 2, height: 2.65)
        layer.shadowRadius = 2.8
        layer.shadowOpacity = 0.5
        layer.masksToBounds = false
    }
}

extension ShadowView where Self: UIButton {
    func addShadow() {
        layer.shadowOffset = CGSize(width: 0, height: 0.1)
        layer.shadowRadius = 0.5
        layer.shadowOpacity = 0.6
        layer.masksToBounds = false
    }
}
