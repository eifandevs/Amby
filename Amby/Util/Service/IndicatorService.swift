//
//  IndicatorService.swift
//  Amby
//
//  Created by tenma.i on 2019/11/18.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import UIKit

/// 通知マネージャー
class IndicatorService {
    static let s = IndicatorService()
    let indicator = UIActivityIndicatorView()

    private init() {
        if let window = (UIApplication.shared.delegate as? AppDelegate)?.window {
            indicator.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
            indicator.center = window.center
            // アニメーションが止まった時にindecatorを隠すかどうか
            indicator.hidesWhenStopped = false
            indicator.activityIndicatorViewStyle = .gray
            indicator.isUserInteractionEnabled = false
            indicator.isHidden = true
            window.addSubview(indicator)
        }
    }

    /// くるくる表示
    func showCircleIndicator() {
        indicator.isHidden = false
        UIApplication.shared.beginIgnoringInteractionEvents()
        indicator.startAnimating()
    }

    func dismissCircleIndicator() {
        indicator.stopAnimating()
        indicator.isHidden = true
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}
