//
//  Util.swift
//  Eiger
//
//  Created by temma on 2017/02/14.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class Util {
    static let shared: Util = Util()
    private init() {}

    func foregroundViewController() -> UIViewController {
        var vc = UIApplication.shared.keyWindow?.rootViewController;
        while ((vc!.presentedViewController) != nil) {
            vc = vc!.presentedViewController;
        }
        return vc!;
    }
    
    func presentWarning(title: String, message: String) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler:{
            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(defaultAction)
        Util.shared.foregroundViewController().present(alert, animated: true, completion: nil)
    }
    
    func presentSimpleAlert(title: String, message: String, completion: @escaping (() -> ()?)) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            completion()
        })
        alert.addAction(defaultAction)
        Util.shared.foregroundViewController().present(alert, animated: true, completion: nil)
    }
    
    func presentAlert(title: String, message: String, completion: @escaping (() -> ())) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            completion()
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel, handler:{
            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        Util.shared.foregroundViewController().present(alert, animated: true, completion: nil)
    }
}

func *(left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width * right, height: left.height * right)
}

func +(left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width + right.width, height: left.height + right.height)
}

func -(left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width - right.width, height: left.height - right.height)
}

func *(left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width * right.width, height: left.height * right.height)
}

func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
    
}

func *(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

func *(left: CGPoint, right: CGFloat) -> CGPoint {
    return CGPoint(x: left.x * right, y: left.y * right)
}

func *= ( left: inout CGSize, right: CGSize) {
    left = left * right
}

func *= (left: inout CGSize, right: CGFloat) {
    left = left * right
}

func += (left: inout CGSize, right: CGSize) {
    left = left + right
}

func *= (left: inout CGPoint, right: CGPoint) {
    left = left * right
}

func *= (left: inout CGPoint, right: CGFloat) {
    left = left * right
}

func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}
