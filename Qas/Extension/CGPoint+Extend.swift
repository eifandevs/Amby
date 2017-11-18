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

extension CGPoint: ExpressibleByStringLiteral {
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    
    public init(stringLiteral value: StringLiteralType) {
        self.init()
        
        let point:CGPoint;
        if value[value.startIndex] != "{" {
            point = CGPointFromString("{\(value)}")
        } else {
            point = CGPointFromString(value)
        }
        self.x = point.x;
        self.y = point.y;
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(stringLiteral: value)
    }
    
    public typealias UnicodeScalarLiteralType = StringLiteralType
    
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(stringLiteral: value)
    }
}
