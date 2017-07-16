//
//  EGProgressBar.swift
//  Eiger
//
//  Created by tenma on 2017/02/10.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import Bond

class EGProgressBar: UIView {
    private let bar: UIView = UIView()
    let progressMin: CGFloat = 0.1
    var isFinished: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.lightBlue
        bar.backgroundColor = UIColor.frenchBlue
        alpha = 0
        
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
    
    func setProgress(_ progress: CGFloat) {
        if progress == 0 {
            bar.frame.size.width = 0
            self.alpha = 0
            return
        } else if progress == progressMin {
            isFinished = false
            self.bar.frame.size.width = 0
        }
        
        if isFinished == true {
            return
        }
        
        layer.removeAllAnimations()
        
        var completion: ((Bool) -> Void)? = nil
        
        if progress > 0 {
            alpha = 1
            if progress >= 1 {
                isFinished = true
                completion = { finished in
                    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                        self.alpha = 0
                    })
                }
            }
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            self.bar.frame.size.width = self.frame.size.width * progress
        }, completion: completion)
        
    }
}
