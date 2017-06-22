//
//  CircleProgress.swift
//  Eiger
//
//  Created by User on 2017/06/08.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class CircleProgress: UIView {
    
    var circle: UIView! = nil
    var progress: CAShapeLayer! = nil
    var progressTimer: Timer! = nil
    var animationFinishAction: (() -> ())? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.circle = UIView()
        self.circle.layoutIfNeeded()
        createProgress()
        
        self.circle!.layer.addSublayer(progress)
        self.addSubview(self.circle!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public Method
    func start(complition: (() -> ())?) {
        invalidate()
        if let _complition = complition {
            animationFinishAction = _complition
        }
        createProgress()
        progressTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
        progressTimer.fire()
    }
    
    func invalidate() {
        if progressTimer != nil && progressTimer.isValid {
            progressTimer.invalidate()
            animationFinishAction = nil
            progressTimer = nil
            progress.removeFromSuperlayer()
            progress = nil
        }
    }
    
// MARK: Private Method
    func createProgress() {
        let centerPoint = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2)
        let circleRadius : CGFloat = self.bounds.size.width / 2.8
        let circlePath = UIBezierPath(arcCenter: centerPoint, radius: circleRadius, startAngle: CGFloat(-0.5 * M_PI), endAngle: CGFloat(1.5 * M_PI), clockwise: true)
        progress = CAShapeLayer()
        progress.path = circlePath.cgPath
        progress.strokeColor = UIColor.dandilionSeeds.cgColor
        progress.fillColor = UIColor.clear.cgColor
        progress.lineWidth = 2.5
        progress.strokeStart = 0
        progress.strokeEnd = 0
        self.circle!.layer.addSublayer(progress)
    }
    
    func updateProgress(tiemr: Timer) {
        progress.strokeEnd += 0.01
        
        if progress.strokeEnd >= 1.0 {
            // アニメーション終了前
        }
        
        if progress.strokeEnd >= 1.25 {
            // アニメーション終了
            log.debug("circle animation stop")
            progressTimer.invalidate()
            progressTimer = nil
            animationFinishAction?()
        }
    }
    
}
