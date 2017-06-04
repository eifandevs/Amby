//
//  UIViewController+Extend.swift
//  Eiger
//
//  Created by temma on 2017/06/04.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func registerForKeyboardWillShowNotification(usingBlock block: ((NSNotification, CGSize) -> Void)? = nil) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: nil, using: { (notification) -> Void in
            let userInfo = notification.userInfo!
            let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue.size
            block?(notification as NSNotification, keyboardSize)
        })
    }

    func registerForKeyboardDidShowNotification(usingBlock block: ((NSNotification, CGSize) -> Void)? = nil) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardDidShow, object: nil, queue: nil, using: { (notification) -> Void in
            let userInfo = notification.userInfo!
            let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue.size
            block?(notification as NSNotification, keyboardSize)
        })
    }
    
    func registerForKeyboardWillHideNotification(usingBlock block: ((NSNotification, CGSize) -> Void)? = nil) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: nil, using: { (notification) -> Void in
            let userInfo = notification.userInfo!
            let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue.size
            block?(notification as NSNotification, keyboardSize)
        })
    }
}
