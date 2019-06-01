//
//  Optional+Extend.swift
//  Amby
//
//  Created by temma on 2017/07/11.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Foundation

public protocol StringOptionalProtocol {}
extension String: StringOptionalProtocol {}

public extension Optional where Wrapped: StringOptionalProtocol {
    public var isEmpty: Bool {
        if let str = self as? String {
            return str.isEmpty
        }
        return true
    }

    public var isNotEmpty: Bool {
        guard let str = self as? String else {
            return false
        }
        return !str.isEmpty
    }
}
