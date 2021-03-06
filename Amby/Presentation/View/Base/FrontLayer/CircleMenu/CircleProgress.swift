//
//  CircleProgress.swift
//  Eiger
//
//  Created by User on 2017/06/08.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

enum CircleProgressAction {
    case finish
}

class CircleProgress: UIView {
    private var circle: UIView
    private var progress: CAShapeLayer!
    private var progressTimer: Timer!

    /// アクション通知用RX
    let rx_action = PublishSubject<CircleProgressAction>()

    override init(frame: CGRect) {
        circle = UIView()
        circle.layoutIfNeeded()

        super.init(frame: frame)
        createProgress()
        circle.layer.addSublayer(progress)
        addSubview(circle)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log.debug("deinit called.")
    }

    // MARK: Public Method

    func start() {
        invalidate()
        createProgress()
        #if UT
            progressTimer = Timer.scheduledTimer(timeInterval: 100, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        #else
            progressTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        #endif
        progressTimer.fire()
    }

    func invalidate() {
        if progressTimer != nil && progressTimer.isValid {
            progressTimer.invalidate()
            progressTimer = nil
            progress.removeFromSuperlayer()
            progress = nil
        }
    }

    // MARK: Private Method

    func createProgress() {
        let centerPoint = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        let circleRadius: CGFloat = bounds.size.width / 4
        let circlePath = UIBezierPath(arcCenter: centerPoint, radius: circleRadius, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        progress = CAShapeLayer()
        progress.path = circlePath.cgPath
        progress.strokeColor = UIColor.pasteLightGray.cgColor
        progress.fillColor = UIColor.clear.cgColor
        progress.lineWidth = 2.5
        progress.strokeStart = 0
        progress.strokeEnd = 0
        circle.layer.addSublayer(progress)
    }

    @objc func updateProgress(tiemr _: Timer) {
        progress.strokeEnd += 0.01

        if progress.strokeEnd >= 1.15 {
            // アニメーション終了前
            superview?.isUserInteractionEnabled = false
        }

        if progress.strokeEnd >= 1.25 {
            // アニメーション終了
            log.debug("circle animation stop")
            progressTimer.invalidate()
            progressTimer = nil
            rx_action.onNext(.finish)
        }
    }
}
