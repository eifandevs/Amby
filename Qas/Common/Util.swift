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
    
    static func foregroundViewController() -> UIViewController {
        var vc = UIApplication.shared.keyWindow?.rootViewController;
        while ((vc!.presentedViewController) != nil) {
            vc = vc!.presentedViewController;
        }
        return vc!;
    }
    
    static func createFolder(path: String) {
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        
        fileManager.fileExists(atPath: path, isDirectory: &isDir)
        
        if !isDir.boolValue {
            try! fileManager.createDirectory(atPath: path ,withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    static func deleteFolder(path: String) {
        let fileManager = FileManager.default
        var isDir : ObjCBool = false
        
        if fileManager.fileExists(atPath: path, isDirectory: &isDir) {
            try! fileManager.removeItem(atPath: path)
        }
    }
    
    static func findFirstResponder(view: UIView) -> UIView? {
        if view.isFirstResponder {
            return view
        }
        for subview in view.subviews {
            if subview.isFirstResponder {
                return subview
            }
            let responder = findFirstResponder(view: subview)
            if let responder = responder {
                return responder
            }
        }
        return nil
    }
    
    /// キーボードが表示されているか
    static func displayedKeyboard() -> Bool {
        let window: UIWindow? = {
            for w in UIApplication.shared.windows {
                if w.className == "UIRemoteKeyboardWindow" {
                    return w
                }
            }
            return nil
        }()
        if window != nil {
            return true
        } else {
            return false
        }
    }
}

func *(left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width * right, height: left.height * right)
}

func /(left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width / right, height: left.height / right)
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
