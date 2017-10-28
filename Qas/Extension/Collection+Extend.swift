//
//  Collection+Extend.swift
//  Qas
//
//  Created by temma on 2017/07/04.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> _Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}
