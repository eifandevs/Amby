//
//  EGGradientLabel.swift
//  Eiger
//
//  Created by temma on 2017/03/18.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Foundation
import UIKit

class EGGradientLabel: PaddingLabel {
    private let gradient = CAGradientLayer()

    init() {
        super.init(frame: CGRect.zero)
        gradient.colors = [
            UIColor(red: 1, green: 1, blue: 1, alpha: 0).cgColor,
            UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.55, y: 0.0)
        gradient.endPoint = CGPoint(x: 1, y: 0.0)
        layer.addSublayer(gradient)
    }

    deinit {
        log.debug("deinit called.")
    }

    override func layoutSubviews() {
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
