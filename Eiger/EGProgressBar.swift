//
//  EGProgressBar.swift
//  Eiger
//
//  Created by tenma on 2017/02/10.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import YLProgressBar

class EGProgressBar: YLProgressBar {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.type = YLProgressBarType.flat
        self.setProgress(0, animated: false)
        self.progress = 0
        self.progressTintColors = [UIColor.orange, UIColor.blazingYellow]
        self.hideStripes = true
        self.hideGloss = true
        self.hideTrack = true
        self.progressStretch = false
        self.backgroundColor = UIColor.clear
        self.trackTintColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initializeProgress() {
        self.setProgress(0, animated: false)
        self.progress = 0
        removeFromSuperview()
    }
}
