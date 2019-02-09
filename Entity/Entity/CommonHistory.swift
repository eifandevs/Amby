//
//  CommonHistory.swift
//  Qas
//
//  Created by temma on 2017/11/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

// swiftlint:disable force_cast

public class CommonHistory: NSObject, NSCoding {
    public var _id: String = NSUUID().uuidString
    public var url: String = ""
    public var title: String = ""
    public var date: Date = Date()

    override init() {
        super.init()
    }

    public init(_id: String = NSUUID().uuidString, url: String, title: String, date: Date) {
        self._id = _id
        self.url = url
        self.title = title
        self.date = date
    }

    public required convenience init?(coder decoder: NSCoder) {
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
