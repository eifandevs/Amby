//
//  CGPoint+Extend.swift
//  Qas
//
//  Created by User on 2017/06/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint {
    func distance(pt: CGPoint)  -> CGFloat {
        let x = pow(pt.x - self.x, 2)
        let y = pow(pt.y - self.y, 2)
        return sqrt(x + y)
    }
}
