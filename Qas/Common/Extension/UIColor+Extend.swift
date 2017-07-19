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
    /// サークル画像を作成
    func circleImage(size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(self.cgColor)
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
    
    static var deepOrange: UIColor {
        return UIColor(red: 255/255, green: 127/255, blue: 0/255, alpha: 1)
    }
    
    static var frenchBlue: UIColor {
        return UIColor(red: 0/255, green: 175/255, blue: 240/255, alpha: 1)
    }
    
    static var lightBlue: UIColor {
        return UIColor(red: 173/255, green: 225/255, blue: 247/255, alpha: 1)
    }
    
    static var blueGray: UIColor {
        return UIColor(red: 44/255, green: 71/255, blue: 98/255, alpha: 1)
    }
    
    static var rasberry: UIColor {
        return UIColor(red: 219 / 255, green: 74 / 255, blue: 57 / 255, alpha: 1)
    }
    
    static var blazingYellow: UIColor {
        return UIColor(red: 255/255, green: 195/255, blue: 0/255, alpha: 1)
    }
    
    static var pastelLightGray: UIColor {
        return UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
    }
    
    static var dandilionSeeds: UIColor {
        return UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    }
    
    static var blind: UIColor {
        return UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1)
    }
    
    static var limoges: UIColor {
        return UIColor(red: 0/255, green: 99/255, blue: 220/255, alpha: 1)
    }
    
    static var oasis: UIColor {
        return UIColor(red: 227 / 255, green: 227 / 255, blue: 227 / 255, alpha: 1)
    }
    
    static var placid: UIColor {
        return UIColor(red: 0 / 255, green: 114 / 255, blue: 181 / 255, alpha: 1)
    }
    
    static var magenta: UIColor {
        return UIColor(red: 127 / 255, green: 39 / 255, blue: 127 / 255, alpha: 1)
    }
    
    static var lightGreen: UIColor {
        return UIColor(red: 29/255, green: 205/255, blue: 0/255, alpha: 1)
    }
    
    static var popOrange: UIColor {
        return UIColor(red: 255/255, green: 121/255, blue: 19/255, alpha: 1)
    }
}
