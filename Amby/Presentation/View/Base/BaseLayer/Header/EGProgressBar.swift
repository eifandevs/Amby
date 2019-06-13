//
//  EGProgressBar.swift
//  Eiger
//
//  Created by tenma on 2017/02/10.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Foundation
import UIKit

class EGProgressBar: UIView {
    private let bar: UIView = UIView()
    private let progressMin: CGFloat = 0.1
    private var isFinished: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.lightUltraViolet
        bar.backgroundColor = UIColor.ultraViolet
        alpha = 0

        addSubview(bar)
    }

    deinit {
        log.debug("deinit called.")
    }

    required init?(coder _: NSCoder) {
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
            alpha = 0
            return
        } else if progress == progressMin {
            isFinished = false
            bar.frame.size.width = 0
        }

        if isFinished == true {
            return
        }

        layer.removeAllAnimations()

        var completion: ((Bool) -> Void)?

        if progress > 0 {
            alpha = 1
            if progress >= 1 {
                isFinished = true
                completion = { _ in
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
