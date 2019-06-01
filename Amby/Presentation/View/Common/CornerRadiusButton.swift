//
//  CornerRadiusButton.swift
//  Amby
//
//  Created by temma on 2017/11/12.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable

class CornerRadiusButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 5.0

    override func draw(_: CGRect) {
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
    }
}
