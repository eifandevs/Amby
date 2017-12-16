//
//  CircleMenu.swift
//  Eiger
//
//  Created by User on 2017/06/06.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

protocol CircleMenuDelegate: class {
    func circleMenuDidClose()
    func circleMenuDidActive()
}

class CircleMenu: UIButton, ShadowView, CircleView {
    weak var delegate: CircleMenuDelegate?
    private var swipeDirection: EdgeSwipeDirection!

    private var initialPt: CGPoint?
    private var isEdgeSwiping = true
    private var isEdgeClosing = false
    private var isClosing = false
    private var progress: CircleProgress!
    private var circleMenuItemGroup: [[CircleMenuItem]] = []
    private var menuIndex: Int = 0
    private var circleMenuItems: [CircleMenuItem] {
        get {
            return circleMenuItemGroup[menuIndex]
        }
    }
    
    enum CircleMenuLeftLocation: CGPoint, EnumEnumerable {
        case Upper = "0,-130"
        case UpperRight = "62,-100"
        case RightUpper = "100,-39"
        case RightLower = "100,39"
        case LowerRight = "62,100"
        case Lower = "0,130"
        
        static func locations() -> [CGPoint] {
            return CircleMenuLeftLocation.cases.map({ $0.rawValue })
        }
    }
    
    enum CircleMenuRightLocation: CGPoint, EnumEnumerable {
        case Upper = "0,-130"
        case UpperRight = "-62,-100"
        case RightUpper = "-100,-40"
        case RightLower = "-100,40"
        case LowerRight = "-62,100"
        case Lower = "0,130"
        
        static func locations() -> [CGPoint] {
            return CircleMenuRightLocation.cases.map({ $0.rawValue })
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, menuItems: [[CircleMenuItem]], swipeDirection: EdgeSwipeDirection) {
        self.init(frame: frame)
        circleMenuItemGroup = menuItems
        self.swipeDirection = swipeDirection
        // 陰影と角丸
        addCircleShadow()
        addCircle()
        setImage(UIColor.gray.circleImage(size: CGSize(width: 33, height: 33)), for: .normal)
        alpha = 0.4
        
        // 画面タッチイベントの検知
        EGApplication.sharedMyApplication.egDelegate = self
        
        // プログレス
        progress = CircleProgress(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        addSubview(progress)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

// MARK: Public Method
    func invalidate() {
        progress.invalidate()
    }
    
// MARK: Touch Event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if !isEdgeClosing {
            progress.invalidate()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if !isEdgeClosing {
            let touch = touches.first!
            let newPt = touch.location(in: superview!)
            let oldPt = touch.previousLocation(in: superview!)
            let diff = newPt - oldPt
            center = center + diff
            // CircleMenuとCircleMenuItemの重なり検知
            collisionLoop()
            // エッジクローズ検知
            edgeClose()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if !isEdgeClosing {
            // CircleMenu押下判定
            if  center == initialPt! {
                // サークルメニューアイテムを切り替える
                let currentCircleMenuItems = circleMenuItems
                menuIndex = menuIndex + 1 == circleMenuItemGroup.count ? 0 : menuIndex + 1
                for (index, item) in currentCircleMenuItems.enumerated() {
                    circleMenuItems[index].frame = item.frame
                    circleMenuItems[index].addTarget(self, action: #selector(self.tappedCircleMenuItem(_:)), for: .touchUpInside)
                    superview!.addSubview(circleMenuItems[index])
                    item.removeFromSuperview()
                }
            }
            startCloseAnimation()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
// MARK: Private Method
    private func closeCircleMenuItems() {
        if self.executeCircleMenuAction() {
            isClosing = true
            progress.invalidate()
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 0
                self.circleMenuItems.forEach({ (menuItem) in
                    if menuItem.scheduledAction {
                        menuItem.transform = CGAffineTransform(scaleX: 2, y: 2)
                        menuItem.setImage(image: menuItem.imageView?.image, color: UIColor.white)
                        menuItem.backgroundColor = UIColor.brilliantBlue
                    } else {
                        menuItem.center = self.initialPt!
                        menuItem.alpha = 0
                    }
                })
            }, completion: { (finished) in
                if finished {
                    self.alpha = 0
                    self.circleMenuItems.forEach({ (menuItem) in
                        if menuItem.scheduledAction {
                            UIView.animate(withDuration: 0.2, animations: {
                                menuItem.alpha = 0
                            }, completion: { (finished) in
                                if finished {
                                    self.delegate?.circleMenuDidClose()
                                }
                            })
                        } else {
                            menuItem.alpha = 0
                        }
                    })
                }
            })
        } else {
            self.progress.start {
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 0
                    self.circleMenuItems.forEach({ (menuItem) in
                        menuItem.center = self.initialPt!
                        menuItem.alpha = 0
                    })
                }, completion: { (finished) in
                    if finished {
                        self.delegate?.circleMenuDidClose()
                    }
                })
            }
        }
    }
    
    /// サークルメニューのクローズ
    private func startCloseAnimation() {
        if self.initialPt != nil {
            UIView.animate(withDuration: 0.15, animations: {
                self.center = self.initialPt!
            }) { (finished) in
                if finished {
                    self.closeCircleMenuItems()
                }
            }
        } else {
            // エッジスワイプしたが、すぐに離したためMOVEまでイベントがいかないパターン
            log.debug("edge swipe cancelled.")
            isClosing = true
            delegate?.circleMenuDidClose()
        }
    }
    
    /// エッジクローズの検知
    private func edgeClose() {
        if center.x < AppConst.FRONT_LAYER_EDGE_SWIPE_EREA * 0.98 {
            isEdgeClosing = true
            isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.2, animations: {
                self.center.x = -1 * self.frame.size.width / 2
                self.circleMenuItems.forEach({ (item) in
                    item.center = CGPoint(x: -1 * self.frame.size.width, y: self.center.y)
                })
            }, completion: { (finished) in
                if finished {
                    self.delegate?.circleMenuDidClose()
                }
            })
        } else if center.x > DeviceConst.DISPLAY_SIZE.width * 0.98 {
            isEdgeClosing = true
            isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.2, animations: {
                self.center.x = DeviceConst.DISPLAY_SIZE.width + self.frame.size.width / 2
                self.circleMenuItems.forEach({ (item) in
                    item.center = CGPoint(x: DeviceConst.DISPLAY_SIZE.width + self.frame.size.width, y: self.center.y)
                })
            }, completion: { (finished) in
                if finished {
                    self.delegate?.circleMenuDidClose()
                }
            })
        }
    }
    
    private func collisionLoop() {
        // CircleMenuとCircleMenuItemの重なりを検知
        for item in self.circleMenuItems {
            if (detectCollision(item: item)) {
                if item.isValid == false && item.scheduledAction == false {
                    // 他のitemを無効にする
                    for v in self.circleMenuItems {
                        v.scheduledAction = false
                        v.setImage(image: v.imageView?.image, color: UIColor.darkGray)
                        v.backgroundColor = UIColor.white
                    }
                    
                    item.scheduledAction = true
                    item.isValid = true
                    item.setImage(image: item.imageView?.image, color: UIColor.white)
                    item.backgroundColor = UIColor.brilliantBlue
                    UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn, animations: {
                        item.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    }, completion: nil)
                }
            } else {
                if item.isValid {
                    item.isValid = false
                    item.setImage(image: item.imageView?.image, color: UIColor.darkGray)
                    item.backgroundColor = UIColor.white
                    if item.scheduledAction {
                        // 他のValidなitemをアクション予約する
                        for v in self.circleMenuItems where v.isValid {
                            v.scheduledAction = true
                            v.setImage(image: v.imageView?.image, color: UIColor.white)
                            v.backgroundColor = UIColor.brilliantBlue
                        }
                    }
                    item.scheduledAction = false
                    UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
                        item.transform = CGAffineTransform.identity
                    }, completion: nil)
                }
                
            }
        }
    }
    
    private func detectCollision(item: CircleMenuItem) -> Bool {
        let distance = center.distance(pt: item.center)
        if (distance < (((bounds.size.width * 1.5) / 2) + (item.bounds.size.width / 2))) {
            return true
        }
        return false
    }
    
    private func executeCircleMenuAction() -> Bool {
        for item in circleMenuItems {
            if item.scheduledAction {
                item.action?(initialPt!)
                return true
            }
        }
        return false
    }
    
// MARK: Button Event
    @objc func tappedCircleMenuItem(_ sender: AnyObject) {
        if !isClosing {
            (sender as! CircleMenuItem).scheduledAction = true
            closeCircleMenuItems()
        }
    }
}

// MARK: EGApplication Delegate
extension CircleMenu: EGApplicationDelegate {
    internal func screenTouchBegan(touch: UITouch) {
    }
    
    internal func screenTouchMoved(touch: UITouch) {
        if !isEdgeClosing && isEdgeSwiping {
            let pt = touch.location(in: superview!)
            center = pt
            
            // CircleMenuItemを作成する
            if initialPt == nil {
                // サークルメニューが作成されることを伝える
                delegate?.circleMenuDidActive()
                initialPt = pt
                let circleMenuLocations = swipeDirection == .left ? CircleMenuLeftLocation.locations() : CircleMenuRightLocation.locations()
                for (index, circleMenuItem) in circleMenuItems.enumerated() {
                    circleMenuItem.frame.size = frame.size
                    circleMenuItem.center = initialPt!
                    circleMenuItem.addTarget(self, action: #selector(self.tappedCircleMenuItem(_:)), for: .touchUpInside)
                    superview!.addSubview(circleMenuItem)
                    UIView.animate(withDuration: 0.18, animations: {
                        circleMenuItem.center = self.center + circleMenuLocations[index]
                    })
                }
            }
            
            // CircleMenuとCircleMenuItemの重なり検知
            collisionLoop()
            // エッジクローズを検知する
            edgeClose()
        }
    }
    
    internal func screenTouchEnded(touch: UITouch) {
        if !isEdgeClosing && isEdgeSwiping {
            isEdgeSwiping = false
            startCloseAnimation()
        }
    }
    
    internal func screenTouchCancelled(touch: UITouch) {
        screenTouchEnded(touch: touch)
    }
}
