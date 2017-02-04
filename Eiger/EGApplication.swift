//
//  EGApplication.swift
//  sample
//
//  Created by tenma on 2017/01/30.
//  Copyright © 2017年 tenma. All rights reserved.
//

import Foundation
import UIKit

@objc protocol EGApplicationDelegate {
    func screenTouchBegan(touch: UITouch)
    func screenTouchMoved(touch: UITouch)
    func screenTouchEnded(touch: UITouch)
    func screenTouchCancelled(touch: UITouch)
}

@objc(EGApplication) class EGApplication: UIApplication {
    weak var egDelegate: EGApplicationDelegate?
    static let sharedMyApplication = UIApplication.shared as! EGApplication
    
    override func sendEvent(_ event: UIEvent) {
        if event.type == .touches {
            if let touches = event.allTouches, let touch = touches.first, touches.count == 1 {
                switch touch.phase {
                    case .began:
                        self.egDelegate?.screenTouchBegan(touch: touch)
                    case .moved:
                        self.egDelegate?.screenTouchMoved(touch: touch)
                    case .ended:
                        self.egDelegate?.screenTouchEnded(touch: touch)
                    case .cancelled:
                        self.egDelegate?.screenTouchCancelled(touch: touch)
                    default: break
                }
            }
        }
        super.sendEvent(event)
    }
}
