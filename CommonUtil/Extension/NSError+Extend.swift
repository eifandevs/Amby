//
//  NSError+Extend.swift
//  CommonUtil
//
//  Created by tenma.i on 2019/10/02.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation

public extension NSError {
    static public var empty: Error {
        return NSError(domain: "", code: 0, userInfo: nil)
    }
}
