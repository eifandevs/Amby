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
    var url: String = ""
    var name: String = ""
    
    override init() {
        super.init()
    }
    
    init(url: String, name: String) {
        self.url = url
        self.name = name
    }
    
    required convenience init?(coder decoder: NSCoder) {
        let url = decoder.decodeObject(forKey: "url") as! String
        let name = decoder.decodeObject(forKey: "name") as! String
        self.init(url: url, name: name)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(url, forKey: "url")
        aCoder.encode(name, forKey: "name")
    }
}
