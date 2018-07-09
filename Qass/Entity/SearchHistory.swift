//
//  SearchHistory.swift
//  Qas
//
//  Created by temma on 2017/11/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

// swiftlint:disable force_cast

class SearchHistory: NSObject, NSCoding {
    var _id: String = NSUUID().uuidString
    var title: String = ""
    var date: Date = Date()

    override init() {
        super.init()
    }

    init(_id: String = NSUUID().uuidString, title: String, date: Date) {
        self._id = _id
        self.title = title
        self.date = date
    }

    required convenience init?(coder decoder: NSCoder) {
        let _id = decoder.decodeObject(forKey: "_id") as! String
        let title = decoder.decodeObject(forKey: "title") as! String
        let date = decoder.decodeObject(forKey: "date") as! Date
        self.init(_id: _id, title: title, date: date)
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(_id, forKey: "_id")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(date, forKey: "date")
    }
}
