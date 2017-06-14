//
//  EachHistoryItem.swift
//  Eiger
//
//  Created by tenma on 2017/02/16.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class EachHistoryItem: NSObject, NSCoding {
    var context: String = NSUUID().uuidString
    var url: String = ""
    var title: String = ""

    override init() {
        super.init()
    }
    
    init(url: String) {
        self.url = url
    }
    
    init(url: String, title: String) {
        self.url = url
        self.title = title
    }
    
    init(context: String, url: String, title: String) {
        self.context = context
        self.url = url
        self.title = title
    }
    
    required convenience init?(coder decoder: NSCoder) {
        let context = decoder.decodeObject(forKey: "context") as! String
        let url = decoder.decodeObject(forKey: "url") as! String
        let title = decoder.decodeObject(forKey: "title") as! String
        self.init(context: context, url: url, title: title)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(context, forKey: "context")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(title, forKey: "title")
    }
}
