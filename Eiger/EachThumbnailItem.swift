//
//  EachFooterItem.swift
//  Eiger
//
//  Created by tenma on 2017/03/24.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class EachThumbnailItem: NSObject, NSCoding {
    var context: String = ""
    var url: String = ""
    
    override init() {
        super.init()
    }
    
    init(url: String, context: String) {
        self.url = url
        self.context = context
    }
    
    required convenience init?(coder decoder: NSCoder) {
        let url = decoder.decodeObject(forKey: "url") as! String
        let context = decoder.decodeObject(forKey: "context") as! String
        self.init(url: url, context: context)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(url, forKey: "url")
        aCoder.encode(context, forKey: "context")
    }
}
