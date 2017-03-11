//
//  WKWebView+Extend.swift
//  Eiger
//
//  Created by temma on 2017/02/26.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import WebKit

private var requestUrlAssociationKey: UInt8 = 0
private var requestTitleAssociationKey: UInt8 = 0

extension WKWebView {
    
    // 最新のリクエストURLを常に保持しておく
    // 履歴保存時やリロード時に使用する
    var requestUrl: String! {
        get {
            return objc_getAssociatedObject(self, &requestUrlAssociationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &requestUrlAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var requestTitle: String! {
        get {
            return objc_getAssociatedObject(self, &requestTitleAssociationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &requestTitleAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func evaluate(script: String, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        var finished = false
        
        evaluateJavaScript(script) { (result, error) in
            if error == nil {
                if result != nil {
                    completion(result as AnyObject?, nil)
                }
            } else {
                completion(nil, error as NSError?)
            }
            finished = true
        }
        
        while !finished {
            RunLoop.current.run(mode: RunLoopMode(rawValue: "NSDefaultRunLoopMode"), before: NSDate.distantFuture)
        }
    }
}
