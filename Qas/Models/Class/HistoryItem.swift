//
//  HistoryItem.swift
//  Eiger
//
//  Created by tenma on 2017/02/16.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class HistoryItem: NSObject, NSCoding {
    var context: String = NSUUID().uuidString
    var isPrivate: String = UserDefaults.standard.string(forKey: AppConst.privateModeKey)!
    var url: String = ""
    var title: String = ""

    override init() {
        super.init()
    }
    
    init(context: String = NSUUID().uuidString, url: String = "", title: String = "", isPrivate: String = UserDefaults.standard.string(forKey: AppConst.privateModeKey)!) {
        self.context = context
        self.url = url
        self.title = title
        self.isPrivate = isPrivate
    }
    
    required convenience init?(coder decoder: NSCoder) {
        let context = decoder.decodeObject(forKey: "context") as! String
        let url = decoder.decodeObject(forKey: "url") as! String
        let title = decoder.decodeObject(forKey: "title") as! String
        let isPrivate = decoder.decodeObject(forKey: "isPrivate") as! String
        self.init(context: context, url: url, title: title, isPrivate: isPrivate)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(context, forKey: "context")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(isPrivate, forKey: "isPrivate")
    }
}
