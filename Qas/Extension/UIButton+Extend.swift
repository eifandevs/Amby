//
//  UIButton+Extend.swift
//  Qas
//
//  Created by temma on 2017/07/04.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    /// ボタンの画像に色をつける
    func setImage(image: UIImage?, color: UIColor, contentMode: UIViewContentMode = .scaleAspectFit) {
        let tintedImage = image?.withRenderingMode(.alwaysTemplate)
        tintColor = color
        imageView?.contentMode = contentMode
        setImage(tintedImage, for: .normal)
    }

    func setBackgroundImage(image: UIImage?, color: UIColor, contentMode: UIViewContentMode = .scaleAspectFit) {
        let tintedImage = image?.withRenderingMode(.alwaysTemplate)
        tintColor = color
        imageView?.contentMode = contentMode
        setBackgroundImage(tintedImage, for: .normal)
    }
}
