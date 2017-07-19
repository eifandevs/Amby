//
//  HistoryItem.swift
//  Eiger
//
//  Created by tenma on 2017/02/16.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class CommonHistoryItem: NSObject, NSCoding {
    var _id: String = ""
    var url: String = ""
    var title: String = ""
    var date: Date = Date()
    
    override init() {
        super.init()
    }
    
    init(_id: String, url: String, title: String, date: Date) {
        self._id = _id
        self.url = url
        self.title = title
        self.date = date
    }
    
    required convenience init?(coder decoder: NSCoder) {
        let _id = decoder.decodeObject(forKey: "_id") as! String
        let url = decoder.decodeObject(forKey: "url") as! String
        let title = decoder.decodeObject(forKey: "title") as! String
        let date = decoder.decodeObject(forKey: "date") as! Date
        self.init(_id: _id, url: url, title: title, date: date)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(_id, forKey: "_id")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(date, forKey: "date")
    }
}

