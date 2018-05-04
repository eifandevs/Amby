//
//  UIViewController+Extend.swift
//  Qass-Develop
//
//  Created by tenma on 2018/04/05.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    // ログ出力用
    @objc func proj_viewDidLoad() {
        proj_viewDidLoad()
        let viewControllerName = NSStringFromClass(type(of: self))
        log.verbose("\(viewControllerName) viewDidLoad.")
    }

    private static let swizzling: (UIViewController.Type) -> Void = { viewController in

        let originalSelector = #selector(viewController.viewDidLoad)
        let swizzledSelector = #selector(viewController.proj_viewDidLoad)

        let originalMethod = class_getInstanceMethod(viewController, originalSelector)
        let swizzledMethod = class_getInstanceMethod(viewController, swizzledSelector)

        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }

    public static func swizzle() {
        _ = swizzling(self)
    }
}
