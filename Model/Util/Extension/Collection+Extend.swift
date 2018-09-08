//
//  Collection+Extend.swift
//  Model
//
//  Created by tenma on 2018/09/08.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}
