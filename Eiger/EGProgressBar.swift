//
//  EGProgressBar.swift
//  Eiger
//
//  Created by tenma on 2017/02/10.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import YLProgressBar

class EGProgressBar: UIView {
    var progress: CGFloat = 0
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

    func setProgress(_ progress: CGFloat, animated: Bool) {
        log.debug("set progress. progress: \(frame.size.width * progress)")
        bar.frame.size.width = frame.size.width * progress
//        frame.size.width = width * progress
    }
    
    func initializeProgress() {
        self.setProgress(0, animated: false)
        self.progress = 0
    }
}
