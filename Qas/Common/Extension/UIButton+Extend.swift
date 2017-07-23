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
    func setImage(image: UIImage?, color: UIColor) {
        let tintedImage = image?.withRenderingMode(.alwaysTemplate)
        tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        imageView?.contentMode = .scaleAspectFit
        setImage(tintedImage, for: .normal)
    }
    
}
