//
//  Collection+Extend.swift
//  Qas
//
//  Created by temma on 2017/07/04.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

public extension Collection {
    public subscript(safe index: Index) -> Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}
