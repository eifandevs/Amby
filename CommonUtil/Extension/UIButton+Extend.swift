//
//  UIButton+Extend.swift
//  Amby
//
//  Created by temma on 2017/07/04.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Foundation
import UIKit

public extension UIButton {
    /// ボタンの画像に色をつける
    public func setImage(image: UIImage?, color: UIColor, contentMode: UIView.ContentMode = .scaleAspectFit) {
        let tintedImage = image?.withRenderingMode(.alwaysTemplate)
        tintColor = color
        imageView?.contentMode = contentMode
        setImage(tintedImage, for: .normal)
    }

    public func setBackgroundImage(image: UIImage?, color: UIColor, contentMode: UIView.ContentMode = .scaleAspectFit) {
        let tintedImage = image?.withRenderingMode(.alwaysTemplate)
        tintColor = color
        imageView?.contentMode = contentMode
        setBackgroundImage(tintedImage, for: .normal)
    }
}
