//
//  NSObject+Extend.swift
//  Amby
//
//  Created by temma on 2017/07/10.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

public extension NSObject {
    public class var className: String {
        return String(describing: self)
    }

    public var className: String {
        return type(of: self).className
    }
}
