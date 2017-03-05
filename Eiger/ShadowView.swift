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
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.shadowRadius = 0.3
        layer.shadowOpacity = 0.4
        layer.masksToBounds = false
    }
}
