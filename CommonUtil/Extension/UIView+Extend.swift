//
//  UIViewController+Extend.swift
//  Eiger
//
//  Created by temma on 2017/06/04.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    /// 全てのサブビュー削除
    public func removeAllSubviews() {
        subviews.forEach {
            $0.removeFromSuperview()
        }
    }

    public func getImage() -> UIImage {
        // キャプチャする範囲を取得.
        let rect = bounds

        // ビットマップ画像のcontextを作成.
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!

        // 対象のview内の描画をcontextに複写する.
        layer.render(in: context)

        // 現在のcontextのビットマップをUIImageとして取得.
        let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!

        // contextを閉じる.
        UIGraphicsEndImageContext()

        return capturedImage
    }
}
