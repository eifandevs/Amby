//
//  UIImageView+Extend.swift
//  Qas
//
//  Created by temma on 2017/07/23.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

public extension UIImageView {
    public func setImage(image: UIImage?, color: UIColor) {
        let tintedImage = image?.withRenderingMode(.alwaysTemplate)
        tintColor = color
        self.image = tintedImage
    }
}
