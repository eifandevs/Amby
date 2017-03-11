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

extension WKWebView {
    
    // 最新のリクエストURLを常に保持しておく
    // 履歴保存時やリロード時に使用する
    var requestUrl: URL! {
        get {
            return objc_getAssociatedObject(self, &requestUrlAssociationKey) as? URL
        }
        set(newValue) {
            objc_setAssociatedObject(self, &requestUrlAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}
