//
//  EGApplication.swift
//  sample
//
//  Created by tenma on 2017/01/30.
//  Copyright © 2017年 tenma. All rights reserved.
//

import Foundation
import UIKit

@objc protocol EGApplicationDelegate: class {
    func screenTouchBegan(touch: UITouch)
    func screenTouchMoved(touch: UITouch)
    func screenTouchEnded(touch: UITouch)
    func screenTouchCancelled(touch: UITouch)
}

// swiftlint:disable force_cast

@objc(EGApplication) class EGApplication: UIApplication {
    weak var egDelegate: EGApplicationDelegate?
    private let movieClassName = "AVPlaybackControlsView"
    static let sharedMyApplication = UIApplication.shared as! EGApplication

    override func sendEvent(_ event: UIEvent) {
        // hook touch event for webview
        if event.type == .touches {
            if let touches = event.allTouches, let touch = touches.first, touches.count == 1 {
                // 動画を全画面表示しているときは、無効
                if touch.view?.className != movieClassName {
                    switch touch.phase {
                    case .began:
                        egDelegate?.screenTouchBegan(touch: touch)
                    case .moved:
                        egDelegate?.screenTouchMoved(touch: touch)
                    case .ended:
                        egDelegate?.screenTouchEnded(touch: touch)
                    case .cancelled:
                        egDelegate?.screenTouchCancelled(touch: touch)
                    default: break
                    }
                }
            }
        }
        super.sendEvent(event)
    }
}

// swiftlint:enable force_cast
