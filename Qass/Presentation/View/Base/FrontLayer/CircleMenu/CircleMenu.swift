//
//  CircleMenu.swift
//  Eiger
//
//  Created by User on 2017/06/06.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import CoreLocation
import Foundation
import Model
import RxCocoa
import RxSwift
import UIKit

class CircleMenu: UIButton, ShadowView, CircleView {
    // メニュークローズ通知用RX
    let rx_circleMenuDidClose = PublishSubject<()>()
    // メニューアクティブ通知用RX
    let rx_circleMenuDidActive = PublishSubject<()>()
    // ボタン押下通知用RX
    let rx_circleMenuDidSelect = PublishSubject<(operation: UserOperation, point: CGPoint)>()

    private let viewModel = CircleMenuViewModel()

    private var swipeDirection: EdgeSwipeDirection!

    private var initialPt: CGPoint?
    private var isEdgeSwiping = true
    private var isEdgeClosing = false
    private var isClosing = false
    private var progress: CircleProgress!
    private var circleMenuItemGroup: [[CircleMenuItem]] = []
    private var circleMenuItems: [CircleMenuItem] {
        return circleMenuItemGroup[viewModel.menuIndex]
    }

    let disposeBag = DisposeBag()

    enum CircleMenuLeftLocation: CGPoint, CaseIterable {
        case upper = "0,-130"
        case upperRight = "62,-100"
        case rightUpper = "100,-40"
        case rightLower = "100,40"
        case lowerRight = "62,100"
        case lower = "0,130"

        static func locations() -> [CGPoint] {
            return CircleMenuLeftLocation.allCases.map({ $0.rawValue })
        }
    }

    enum CircleMenuRightLocation: CGPoint, CaseIterable {
        case upper = "0,-130"
        case upperRight = "-62,-100"
        case rightUpper = "-100,-40"
        case rightLower = "-100,40"
        case lowerRight = "-62,100"
        case lower = "0,130"

        static func locations() -> [CGPoint] {
            return CircleMenuRightLocation.allCases.map({ $0.rawValue })
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(frame: CGRect, swipeDirection: EdgeSwipeDirection) {
        self.init(frame: frame)

        #if UT
            accessibilityIdentifier = "circlemenu"
            log.debug("set accessibility. name: circlemenu")
        #endif

        circleMenuItemGroup = viewModel.menuItems.map { $0.map { CircleMenuItem(operation: $0) } }
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

        setupRx()

        addSubview(progress)
    }

    private func setupRx() {
        progress.rx_circleProgressDidFinish
            .subscribe { [weak self] _ in
                log.eventIn(chain: "rx_circleProgressDidFinish")
                guard let `self` = self else { return }
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 0
                    self.circleMenuItems.forEach({ menuItem in
                        menuItem.center = self.initialPt!
                        menuItem.alpha = 0
                    })
                }, completion: { finished in
                    if finished {
                        self.rx_circleMenuDidClose.onNext(())
                    }
                })
                log.eventOut(chain: "rx_circleProgressDidFinish")
            }
            .disposed(by: disposeBag)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log.debug("deinit called.")
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
            center += diff
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
            if center == initialPt! {
                // サークルメニューアイテムを切り替える
                let currentCircleMenuItems = circleMenuItems
                viewModel.menuIndex = (viewModel.menuIndex + 1 == circleMenuItemGroup.count) ? 0 : (viewModel.menuIndex + 1)
                let nextCircleMenuItems = circleMenuItems
                for (index, item) in currentCircleMenuItems.enumerated() {
                    nextCircleMenuItems[index].frame = item.frame

                    // ボタンタップ
                    nextCircleMenuItems[index].rx.tap
                        .subscribe(onNext: { [weak self] in
                            log.eventIn(chain: "rx_tap")
                            guard let `self` = self else { return }
                            if !self.isClosing {
                                nextCircleMenuItems[index].scheduledAction = true
                                self.closeCircleMenuItems()
                            } else {
                                log.warning("circlemenu already closing.")
                            }
                            log.eventOut(chain: "rx_tap")
                        })
                        .disposed(by: rx.disposeBag)

                    superview!.addSubview(nextCircleMenuItems[index])
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
        if isClosing {
            log.warning("circlemenu already closing.")
            return
        }

        if executeCircleMenuAction() {
            progress.invalidate()
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 0
                self.circleMenuItems.forEach({ menuItem in
                    if menuItem.scheduledAction {
                        menuItem.transform = CGAffineTransform(scaleX: 2, y: 2)
                        menuItem.setImage(image: menuItem.imageView?.image, color: UIColor.white)
                        menuItem.backgroundColor = UIColor.ultraViolet
                    } else {
                        menuItem.center = self.initialPt!
                        menuItem.alpha = 0
                    }
                })
            }, completion: { finished in
                if finished {
                    self.alpha = 0
                    self.circleMenuItems.forEach({ menuItem in
                        if menuItem.scheduledAction {
                            UIView.animate(withDuration: 0.2, animations: {
                                menuItem.alpha = 0
                            }, completion: { finished in
                                if finished {
                                    self.rx_circleMenuDidClose.onNext(())
                                }
                            })
                        } else {
                            menuItem.alpha = 0
                        }
                    })
                }
            })
        } else {
            progress.start()
        }
    }

    /// サークルメニューのクローズ
    private func startCloseAnimation() {
        if initialPt != nil {
            UIView.animate(withDuration: 0.15, animations: {
                self.center = self.initialPt!
            }, completion: { finished in
                if finished {
                    self.closeCircleMenuItems()
                }
            })
        } else {
            // エッジスワイプしたが、すぐに離したためMOVEまでイベントがいかないパターン
            log.debug("edge swipe cancelled.")
            isClosing = true
            rx_circleMenuDidClose.onNext(())
        }
    }

    /// エッジクローズの検知
    private func edgeClose() {
        if center.x < AppConst.FRONT_LAYER.EDGE_SWIPE_EREA * 0.98 {
            isEdgeClosing = true
            isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.2, animations: {
                self.center.x = -1 * self.frame.size.width / 2
                self.circleMenuItems.forEach({ item in
                    item.center = CGPoint(x: -1 * self.frame.size.width, y: self.center.y)
                })
            }, completion: { finished in
                if finished {
                    self.rx_circleMenuDidClose.onNext(())
                }
            })
        } else if center.x > AppConst.DEVICE.DISPLAY_SIZE.width * 0.98 {
            isEdgeClosing = true
            isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.2, animations: {
                self.center.x = AppConst.DEVICE.DISPLAY_SIZE.width + self.frame.size.width / 2
                self.circleMenuItems.forEach({ item in
                    item.center = CGPoint(x: AppConst.DEVICE.DISPLAY_SIZE.width + self.frame.size.width, y: self.center.y)
                })
            }, completion: { finished in
                if finished {
                    self.rx_circleMenuDidClose.onNext(())
                }
            })
        }
    }

    private func collisionLoop() {
        // CircleMenuとCircleMenuItemの重なりを検知
        for item in circleMenuItems {
            if detectCollision(item: item) {
                if item.isValid == false && item.scheduledAction == false {
                    // 他のitemを無効にする
                    for v in circleMenuItems {
                        v.scheduledAction = false
                        v.setImage(image: v.imageView?.image, color: UIColor.darkGray)
                        v.backgroundColor = UIColor.white
                    }

                    item.scheduledAction = true
                    item.isValid = true
                    item.setImage(image: item.imageView?.image, color: UIColor.white)
                    item.backgroundColor = UIColor.ultraViolet
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
                        for v in circleMenuItems where v.isValid {
                            v.scheduledAction = true
                            v.setImage(image: v.imageView?.image, color: UIColor.white)
                            v.backgroundColor = UIColor.ultraViolet
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
        if distance < (((bounds.size.width * 1.5) / 2) + (item.bounds.size.width / 2)) {
            return true
        }
        return false
    }

    private func executeCircleMenuAction() -> Bool {
        for item in circleMenuItems where item.scheduledAction {
            isClosing = true
            rx_circleMenuDidSelect.onNext((operation: item.operation, point: initialPt!))
            return true
        }
        return false
    }
}

// MARK: EGApplication Delegate

extension CircleMenu: EGApplicationDelegate {
    internal func screenTouchBegan(touch _: UITouch) {
    }

    internal func screenTouchMoved(touch: UITouch) {
        if !isEdgeClosing && isEdgeSwiping {
            let pt = touch.location(in: superview!)
            center = pt

            // CircleMenuItemを作成する
            if initialPt == nil {
                // サークルメニューが作成されることを伝える
                rx_circleMenuDidActive.onNext(())
                initialPt = pt
                let circleMenuLocations = swipeDirection == .left ? CircleMenuLeftLocation.locations() : CircleMenuRightLocation.locations()
                for (index, circleMenuItem) in circleMenuItems.enumerated() {
                    circleMenuItem.frame.size = frame.size
                    circleMenuItem.center = initialPt!

                    // ボタンタップ
                    circleMenuItem.rx.tap
                        .subscribe(onNext: { [weak self] in
                            log.eventIn(chain: "rx_tap")
                            guard let `self` = self else { return }
                            if !self.isClosing {
                                circleMenuItem.scheduledAction = true
                                self.closeCircleMenuItems()
                            } else {
                                log.warning("circlemenu already closing.")
                            }
                            log.eventOut(chain: "rx_tap")
                        })
                        .disposed(by: rx.disposeBag)

                    superview!.addSubview(circleMenuItem)
                    UIView.animate(withDuration: 0.18, animations: {
                        if let location = circleMenuLocations[safe: index] {
                            circleMenuItem.center = self.center + location
                        }
                    })
                }
            }

            // CircleMenuとCircleMenuItemの重なり検知
            collisionLoop()
            // エッジクローズを検知する
            edgeClose()
        }
    }

    internal func screenTouchEnded(touch _: UITouch) {
        if !isEdgeClosing && isEdgeSwiping {
            isEdgeSwiping = false
            startCloseAnimation()
        }
    }

    internal func screenTouchCancelled(touch: UITouch) {
        screenTouchEnded(touch: touch)
    }
}
