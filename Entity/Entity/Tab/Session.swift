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
    public var currentPage: Int

    public init(urls: [String] = [],
                currentPage: Int = 0) {
        self.urls = urls
        self.currentPage = currentPage
    }

    public required convenience init?(coder decoder: NSCoder) {
        let urls = decoder.decodeObject(forKey: "urls") as! [String]
        let currentPage = decoder.decodeInteger(forKey: "currentPage")
        self.init(urls: urls, currentPage: currentPage)
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(urls, forKey: "urls")
        aCoder.encode(currentPage, forKey: "currentPage")
    }
}
