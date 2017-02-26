//
//  EachHistoryItem.swift
//  Eiger
//
//  Created by tenma on 2017/02/16.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class CommonHistoryItem: NSObject, NSCoding {
    var url: String = ""
    var title: String = ""
    
    override init() {
        super.init()
    }
    
    init(url: String, title: String) {
        self.url = url
        self.title = title
    }
    
    required convenience init?(coder decoder: NSCoder) {
        let url = decoder.decodeObject(forKey: "url") as! String
        let title = decoder.decodeObject(forKey: "title") as! String
        self.init(url: url, title: title)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(url, forKey: "url")
        aCoder.encode(title, forKey: "title")
    }
}

