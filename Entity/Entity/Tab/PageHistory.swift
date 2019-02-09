//
//  PageHistory.swift
//  Qas
//
//  Created by temma on 2017/11/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

// swiftlint:disable force_cast

public class PageHistory: NSObject, NSCoding {
    /// 操作種別
    public enum Operation: Int {
        case normal = 0
        case back = 1
        case forward = 2
    }

    public var context: String = NSUUID().uuidString
    public var url: String = ""
    public var title: String = ""
    public var backForwardList = [String]()
    public var listIndex: Int = 0
    public var isLoading = false

    override init() {
        super.init()
    }

    public init(context: String = NSUUID().uuidString,
                url: String = "",
                title: String = "",
                backForwardList: [String] = [],
                listIndex: Int = 0,
                isLoading: Bool = false,
                operation _: Int = 0) {
        self.context = context
        self.url = url
        self.title = title
        self.backForwardList = backForwardList
        self.listIndex = listIndex
        self.isLoading = isLoading
    }

    public required convenience init?(coder decoder: NSCoder) {
        let context = decoder.decodeObject(forKey: "context") as! String
        let url = decoder.decodeObject(forKey: "url") as! String
        let title = decoder.decodeObject(forKey: "title") as! String
        let backForwardList = decoder.decodeObject(forKey: "backForwardList") as! [String]
        let listIndex = decoder.decodeInteger(forKey: "listIndex")
        let isLoading = decoder.decodeBool(forKey: "isLoading")
        self.init(context: context, url: url, title: title, backForwardList: backForwardList, listIndex: listIndex, isLoading: isLoading)
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(context, forKey: "context")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(backForwardList, forKey: "backForwardList")
        aCoder.encode(listIndex, forKey: "listIndex")
        aCoder.encode(isLoading, forKey: "isLoading")
    }
}
