//
//  PaddingLabel.swift
//  Amby
//
//  Created by temma on 2017/11/13.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable

class PaddingLabel: UILabel {
    @IBInspectable var padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)

    override func drawText(in rect: CGRect) {
        let newRect = UIEdgeInsetsInsetRect(rect, padding)
        super.drawText(in: newRect)
    }

    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right
        return contentSize
    }
}
