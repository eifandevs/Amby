//
//  UIViewController+Extend.swift
//  Eiger
//
//  Created by temma on 2017/06/04.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

extension UIView {
    // ログ出力用
    @objc func proj_didMoveToSuperview() {
        self.proj_didMoveToSuperview()
        let viewName = NSStringFromClass(type(of: self))
        // TODO: UT設定
    }
    
    private static let swizzling: (UIView.Type) -> () = { view in
        
        let originalSelector = #selector(view.didMoveToSuperview)
        let swizzledSelector = #selector(view.proj_didMoveToSuperview)
        
        let originalMethod = class_getInstanceMethod(view, originalSelector)
        let swizzledMethod = class_getInstanceMethod(view, swizzledSelector)
        
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    public static func swizzle() {
        _ = self.swizzling(self)
    }
    
    /// 全てのサブビュー削除
    func removeAllSubviews() {
        subviews.forEach {
            $0.removeFromSuperview()
        }
    }
}
