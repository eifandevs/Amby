//
//  Session.swift
//  Entity
//
//  Created by tenma on 2019/04/17.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import UIKit

// swiftlint:disable force_cast

public class Session: NSObject, NSCoding {
    public var urls: [String]
    public var currentIndex: Int
    
    public init(urls: [String] = [],
                currentIndex: Int = 0) {
        self.urls = urls
        self.currentIndex = currentIndex
    }
    
    public required convenience init?(coder decoder: NSCoder) {
        let urls = decoder.decodeObject(forKey: "urls") as! [String]
        let currentIndex = decoder.decodeInteger(forKey: "currentIndex")
        self.init(urls: urls, currentIndex: currentIndex)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(urls, forKey: "urls")
        aCoder.encode(currentIndex, forKey: "currentIndex")
    }
}
