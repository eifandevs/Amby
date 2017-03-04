//
//  HeaderView.swift
//  Eiger
//
//  Created by tenma on 2017/03/01.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class HeaderView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.frenchBlue
    }
    
    func expand() {
        UIView.animate(withDuration: 0.1, animations: {
            self.frame.size.height = DeviceDataManager.shared.statusBarHeight * 2.5
            self.frame.origin.y = 0
        })
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
