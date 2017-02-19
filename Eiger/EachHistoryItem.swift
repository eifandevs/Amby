//
//  EachHistoryItem.swift
//  Eiger
//
//  Created by tenma on 2017/02/16.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation

class EachHistoryItem: NSObject, NSCoding {
    var history: [String] = []
    var index: Int = -1
    
    init(history: [String], index: Int) {
        self.history = history
        self.index = index
    }
    
    required convenience init?(coder decoder: NSCoder) {
        let history = decoder.decodeObject(forKey: "history") as! [String]
        let index = decoder.decodeObject(forKey: "index") as! Int
        self.init(history: history, index: index)
    }
    
    func add(urlStr: String) {
        history.append(urlStr)
        index = index + 1
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(history, forKey: "history")
        aCoder.encode(index, forKey: "index")
    }
}
