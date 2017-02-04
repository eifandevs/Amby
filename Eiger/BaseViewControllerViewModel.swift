//
//  BaseViewControllerViewModel.swift
//  Eiger
//
//  Created by temma on 2017/02/05.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class BaseViewControllerViewModel: UIView, WKNavigationDelegate, UIScrollViewDelegate, UIWebViewDelegate, WKUIDelegate, EGApplicationDelegate {
    
    private let webView = EGWebView()
    init() {
        super.init(frame: CGRect.zero)
        EGApplication.sharedMyApplication.egDelegate = self
        addSubview(webView)
    }
    
    override func layoutSubviews() {
        webView.frame = CGRect(origin: CGPoint.zero, size: frame.size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func screenTouchBegan(touch: UITouch) {
        debugLog("began")
    }
    
    internal func screenTouchMoved(touch: UITouch) {
        debugLog("moved")
    }
    
    internal func screenTouchEnded(touch: UITouch) {
        debugLog("ended")
    }
    
    internal func screenTouchCancelled(touch: UITouch) {
        debugLog("cancelled")
    }
}
