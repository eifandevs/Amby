//
//  FrontLayer.swift
//  Eiger
//
//  Created by User on 2017/06/06.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class FrontLayer: UIView {
    let kCircleButtonRadius = 50;
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        let circleMenu = CircleMenu(frame: CGRect(origin: CGPoint(x: 100, y: 100), size: CGSize(width: kCircleButtonRadius, height: kCircleButtonRadius)))
        addSubview(circleMenu)
    }
}
