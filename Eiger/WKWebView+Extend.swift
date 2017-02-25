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
    
    var requestUrl: URL! {
        get {
            return objc_getAssociatedObject(self, &requestUrlAssociationKey) as? URL
        }
        set(newValue) {
            objc_setAssociatedObject(self, &requestUrlAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}
