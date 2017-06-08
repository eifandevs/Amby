//
//  CircleMenuItem.swift
//  Eiger
//
//  Created by User on 2017/06/08.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class CircleMenuItem: UIView, ShadowView, CircleView {
    
    var action: (() -> ())? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    }
    
    override func didMoveToSuperview() {
        addCircleShadow()
        addCircle()
    }
    
    convenience init(tapAction: (() -> ())?) {
        self.init(frame: CGRect.zero)
        action = tapAction
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
