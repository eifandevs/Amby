//
//  Array+Extend.swift
//  Qas
//
//  Created by temma on 2017/08/01.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

// 配列の重複を削除
extension Array where Element: Equatable {
    var unique: [Element] {
        return reduce([]) { $0.0.contains($0.1) ? $0.0 : $0.0 + [$0.1] }
    }
}
