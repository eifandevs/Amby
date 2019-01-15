//
//  UIColor+Extend.swift
//  Eiger
//
//  Created by tenma on 2017/02/10.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: red.f / 255, green: green.f / 255, blue: blue.f / 255, alpha: 1)
    }

    /// サークル画像を作成
    func circleImage(size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()

        context!.setFillColor(cgColor)
        context!.fillEllipse(in: rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }

    /// 16進で作成
    convenience init(hex: Int, alpha: Double = 1.0) {
        let r = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(hex & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: CGFloat(alpha))
    }

    static var ultraViolet: UIColor {
        return UIColor(hex: 0x5F4B8B, alpha: 1)
    }

    static var lightUltraViolet: UIColor {
        return UIColor.ultraViolet.withAlphaComponent(0.4)
    }

    static var lightGray: UIColor {
        return UIColor(red: 235 / 255, green: 235 / 255, blue: 235 / 255, alpha: 1)
    }

    static var pasteLightGray: UIColor {
        return UIColor(red: 200 / 255, green: 200 / 255, blue: 200 / 255, alpha: 1)
    }

    static var lightGreen: UIColor {
        return UIColor(red: 29 / 255, green: 205 / 255, blue: 0 / 255, alpha: 1)
    }
}
