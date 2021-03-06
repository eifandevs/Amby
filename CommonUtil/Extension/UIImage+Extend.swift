//
//  UIImage+Extend.swift
//  Eiger
//
//  Created by tenma on 2017/03/27.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Foundation
import UIKit

public extension UIImage {
    public func crop(w: Int, h: Int) -> UIImage {
        let origRef = cgImage
        let origWidth = Int(origRef!.width)
        let origHeight = Int(origRef!.height)
        var resizeWidth: Int = 0, resizeHeight: Int = 0

        if origWidth < origHeight {
            resizeWidth = w
            resizeHeight = origHeight * resizeWidth / origWidth
        } else {
            resizeHeight = h
            resizeWidth = origWidth * resizeHeight / origHeight
        }

        let resizeSize = CGSize(width: CGFloat(resizeWidth), height: CGFloat(resizeHeight))

        UIGraphicsBeginImageContext(resizeSize)

        draw(in: CGRect(x: 0, y: 0, width: CGFloat(resizeWidth), height: CGFloat(resizeHeight)))

        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // 切り抜き処理
        let cropRect = CGRect(x: CGFloat((resizeWidth - w) / 2), y: 0, width: CGFloat(w), height: CGFloat(h))
        let cropRef = resizeImage!.cgImage!.cropping(to: cropRect)
        let cropImage = UIImage(cgImage: cropRef!)

        return cropImage
    }
}
