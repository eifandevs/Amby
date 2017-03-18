//
//  EGGradientLabel.swift
//  Eiger
//
//  Created by temma on 2017/03/18.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class EGGradientLabel: UILabel {
    let gradient = CAGradientLayer.init()
    
    init() {
        super.init(frame: CGRect.zero)
        gradient.colors = [
            UIColor.init(red: 1, green: 1, blue: 1, alpha: 0).cgColor,
            UIColor.init(red: 1, green: 1, blue: 1, alpha: 1).cgColor]
        gradient.startPoint = CGPoint(x: 0.76, y: 0.0)
        gradient.endPoint = CGPoint(x: 1, y: 0.0)
        layer.addSublayer(gradient)
    }
    
    override func layoutSubviews() {
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
