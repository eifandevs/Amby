//
//  HeaderViewModel.swift
//  Eiger
//
//  Created by temma on 2017/04/30.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class HeaderViewModel {
    // 通知センター
    let center = NotificationCenter.default
    
// MARK: Public Method
    
    func notifyChangeWebView(text: String) {
        center.post(name: .baseViewSearchWebView, object: text)
    }
}
