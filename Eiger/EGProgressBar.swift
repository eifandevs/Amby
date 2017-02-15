//
//  EGProgressBar.swift
//  Eiger
//
//  Created by tenma on 2017/02/10.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import YLProgressBar
import Bond

class EGProgressBar: UIView {
    private let bar: UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.lightGray
        bar.backgroundColor = UIColor.red
        
        addSubview(bar)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        // widthはsetProgressで決定する
        bar.frame.origin = CGPoint.zero
        bar.frame.size.height = frame.size.height
    }
    
    func removeProgress() {
        initializeProgress()
        removeFromSuperview()
    }

    func setProgress(_ progress: CGFloat) {
        
        if progress > 0 {
            alpha = 1
        }
        
        layer.removeAllAnimations()
        UIView.animate(withDuration: 0.22, animations: {
            self.bar.frame.size.width = self.frame.size.width * progress
        }) { _ in
            if self.bar.frame.size.width == self.frame.size.width {
                UIView.animate(withDuration: 0.3, animations: {
                    self.alpha = 0
                }) { _ in
                    self.bar.frame.size.width = 0
                }
            }
        }
        
    }
    
    func initializeProgress() {
        bar.frame.size.width = 0
        self.alpha = 0
    }
}
