//
//  NSObject+Extend.swift
//  Qas
//
//  Created by temma on 2017/07/10.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

extension NSObject {
    class var className: String {
        return String(describing: self)
    }
    
    var className: String {
        return type(of: self).className
    }
}
