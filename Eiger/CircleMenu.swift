//
//  CircleMenu.swift
//  Eiger
//
//  Created by User on 2017/06/06.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class CircleMenu: UIView, ShadowView, EGApplicationDelegate {
    var initialPt: CGPoint? = nil
    var isEdgeSwiping = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addShadow()
        backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        layer.cornerRadius = frame.size.width / 2
        EGApplication.sharedMyApplication.egDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: EGApplication Delegate
    internal func screenTouchBegan(touch: UITouch) {
    }
    
    internal func screenTouchMoved(touch: UITouch) {
        if isEdgeSwiping {
            let pt = touch.location(in: superview!)
            if initialPt == nil {
                initialPt = pt
            }
            center = pt
        }
    }
    
    internal func screenTouchEnded(touch: UITouch) {
        if isEdgeSwiping {
            isEdgeSwiping = false
            UIView.animate(withDuration: 0.2, animations: {
                self.center = self.initialPt!
            }) { (finished) in
                if finished {
                    
                }
            }
        }
    }
    
    internal func screenTouchCancelled(touch: UITouch) {
    }
    
}
