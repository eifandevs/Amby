//
//  CircleMenu.swift
//  Eiger
//
//  Created by User on 2017/06/06.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

protocol CircleMenuDelegate {
    func circleMenuDidClose()
}

class CircleMenu: UIView, ShadowView, CircleView, EGApplicationDelegate {
    var delegate: CircleMenuDelegate?

    var initialPt: CGPoint? = nil
    var isEdgeSwiping = true
    var isClosing = false
    var progress: CircleProgress! = nil
    var circleMenuItemGroup: [[CircleMenuItem]] = []
    var menuIndex: Int = 0
    var circleMenuItems: [CircleMenuItem] {
        get {
            return circleMenuItemGroup[menuIndex]
        }
    }
    let circleMenuLocations: [CGPoint] = [
        CGPoint(x: 0, y: -110), // Upper
        CGPoint(x: 57, y: -82), // UpperRight
        CGPoint(x: 92, y: -30), // RightUpper
        CGPoint(x: 92, y:  30), // RightLower
        CGPoint(x: 57, y: 82), // LowerRight
        CGPoint(x: 0, y: 110) // Lower
    ]
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addCircleShadow()
        addCircle()
        backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        alpha = 0.9
        EGApplication.sharedMyApplication.egDelegate = self
        
        // プログレス
        progress = CircleProgress(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        addSubview(progress)
    }
    
    convenience init(frame: CGRect, menuItems: [[CircleMenuItem]]) {
        self.init(frame: frame)
        circleMenuItemGroup = menuItems
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// MARK: EGApplication Delegate
    internal func screenTouchBegan(touch: UITouch) {
    }
    
    internal func screenTouchMoved(touch: UITouch) {
        if !isClosing && isEdgeSwiping {
            let pt = touch.location(in: superview!)
            center = pt

            if initialPt == nil {
                initialPt = pt
                // CircleMenuItemを作成する
                for (index, circleMenuItem) in circleMenuItems.enumerated() {
                    circleMenuItem.frame.size = self.frame.size
                    circleMenuItem.center = initialPt!
                    superview!.addSubview(circleMenuItem)
                    UIView.animate(withDuration: 0.25, animations: { 
                        circleMenuItem.center = self.center + self.circleMenuLocations[index]
                    })
                }
            }
            
            if center.x < AppDataManager.shared.edgeSwipeErea * 0.98 {
                isClosing = true
                isUserInteractionEnabled = false
                UIView.animate(withDuration: 0.2, animations: { 
                    self.center.x = -1 * self.frame.size.width / 2
                }, completion: { (finished) in
                    if finished {
                        self.delegate?.circleMenuDidClose()
                    }
                })
            } else if center.x > DeviceDataManager.shared.displaySize.width * 0.98 {
                isClosing = true
                isUserInteractionEnabled = false
                UIView.animate(withDuration: 0.2, animations: {
                    self.center.x = DeviceDataManager.shared.displaySize.width + self.frame.size.width / 2
                }, completion: { (finished) in
                    if finished {
                        self.delegate?.circleMenuDidClose()
                    }
                })
            }
        }
    }
    
    internal func screenTouchEnded(touch: UITouch) {
        if !isClosing && isEdgeSwiping {
            isEdgeSwiping = false
            startCloseAnimation()
        }
    }
    
    internal func screenTouchCancelled(touch: UITouch) {
        if !isClosing && isEdgeSwiping {
            isEdgeSwiping = false
            startCloseAnimation()
        }
    }
    
// MARK: Touch Event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isClosing {
            progress.invalidate()
            let pt = touches.first!.location(in: superview!)
            initialPt = pt
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isClosing {
            let touch = touches.first!
            let newPt = touch.location(in: superview!)
            let oldPt = touch.previousLocation(in: superview!)
            let diff = newPt - oldPt
            center = center + diff
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isClosing {
            startCloseAnimation()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isClosing {
            startCloseAnimation()
        }
    }
    
// MARK: Private Method
    private func startCloseAnimation() {
        UIView.animate(withDuration: 0.15, animations: {
            self.center = self.initialPt!
        }) { (finished) in
            if finished {
                self.progress.start {
                    UIView.animate(withDuration: 0.15, animations: {
                        self.circleMenuItems.forEach({ (menuItem) in
                            menuItem.center = self.initialPt!
                        })
                    }, completion: { (finished) in
                        if finished {
                            self.delegate?.circleMenuDidClose()
                        }
                    })
                }
            }
        }
    }
    
}
