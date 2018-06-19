//
//  UIViewController+Extend.swift
//  Eiger
//
//  Created by temma on 2017/06/04.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import NSObject_Rx
import RxCocoa
import RxSwift
import UIKit

extension UIView {
    // ログ出力用
    @objc func proj_didMoveToSuperview() {
        proj_didMoveToSuperview()
        let viewName = NSStringFromClass(type(of: self))
        log.debug("set accessibility. identifier: \(viewName)")
        // UT設定
        accessibilityIdentifier = viewName
    }

    private static let swizzling: (UIView.Type) -> Void = { view in

        let originalSelector = #selector(view.didMoveToSuperview)
        let swizzledSelector = #selector(view.proj_didMoveToSuperview)

        let originalMethod = class_getInstanceMethod(view, originalSelector)
        let swizzledMethod = class_getInstanceMethod(view, swizzledSelector)

        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }

    public static func swizzle() {
        _ = swizzling(self)
    }

    /// 全てのサブビュー削除
    func removeAllSubviews() {
        subviews.forEach {
            $0.removeFromSuperview()
        }
    }

    func getImage() -> UIImage {

        // キャプチャする範囲を取得.
        let rect = self.bounds

        // ビットマップ画像のcontextを作成.
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!

        // 対象のview内の描画をcontextに複写する.
        self.layer.render(in: context)

        // 現在のcontextのビットマップをUIImageとして取得.
        let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!

        // contextを閉じる.
        UIGraphicsEndImageContext()

        return capturedImage
    }
}
