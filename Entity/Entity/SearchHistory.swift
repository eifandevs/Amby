//
//  SearchHistory.swift
//  Amby
//
//  Created by temma on 2017/11/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

// swiftlint:disable force_cast

public class SearchHistory: NSObject, NSCoding {
    public var _id: String
    public var title: String
    public var date: Date

    public init(_id: String = NSUUID().uuidString, title: String, date: Date) {
        self._id = _id
        self.title = title
        self.date = date
    }

    public required convenience init?(coder decoder: NSCoder) {
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
