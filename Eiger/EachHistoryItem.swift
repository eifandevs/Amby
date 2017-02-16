//
//  EachHistoryItem.swift
//  Eiger
//
//  Created by tenma on 2017/02/16.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

struct EachHistoryItem {
    var history: [String] = []
    var index: Int = 0
    
    mutating func add(urlStr: String) {
        history.append(urlStr)
        index = index + 1
    }
}
