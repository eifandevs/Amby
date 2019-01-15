//
//  Optional+Extend.swift
//  Qas
//
//  Created by temma on 2017/07/11.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

protocol StringOptionalProtocol {}
extension String: StringOptionalProtocol {}

extension Optional where Wrapped: StringOptionalProtocol {
    var isEmpty: Bool {
        if let str = self as? String {
            return str.isEmpty
        }
        return true
    }

    var isNotEmpty: Bool {
        guard let str = self as? String else {
            return false
        }
        return !str.isEmpty
    }
}
