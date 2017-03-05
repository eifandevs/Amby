//
//  HeaderView.swift
//  Eiger
//
//  Created by tenma on 2017/03/01.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class HeaderView: UIView, ShadowView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addShadow()
        backgroundColor = UIColor.frenchBlue
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
