//
//  Array+Extend.swift
//  Model
//
//  Created by tenma on 2019/01/24.
//  Copyright © 2019年 eifandevs. All rights reserved.
//

import Foundation

extension Array {
    /// 移動
    mutating func move(from: Int, to: Int) -> Array {
        let item = self[from]
        remove(at: from)
        insert(item, at: to)
        return self
    }
}
