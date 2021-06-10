//
//  TabGroup.swift
//  Model
//
//  Created by tenma on 2019/02/02.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import UIKit

// swiftlint:disable force_cast

public class TabGroup: NSObject, NSCoding, Codable {
    public var groupContext: String = NSUUID().uuidString
    public var title = "新しいグループ"
    public var isPrivate = false
    public var currentContext: String
    public var histories: [Tab]
    public var backForwardContextList = [String]()

    public override init() {
        let tab = Tab()
        histories = [tab]
        currentContext = tab.context
        backForwardContextList.append(tab.context)
    }

    public init(groupContext: String, title: String, isPrivate: Bool, currentContext: String, histories: [Tab], backForwardContextList: [String]) {
        self.groupContext = groupContext
        self.title = title
        self.isPrivate = isPrivate
        self.currentContext = currentContext
        self.histories = histories
        self.backForwardContextList = backForwardContextList
    }

    public required convenience init?(coder decoder: NSCoder) {
        let groupContext = decoder.decodeObject(forKey: "groupContext") as! String
        let title = decoder.decodeObject(forKey: "title") as! String
        let isPrivate = decoder.decodeBool(forKey: "isPrivate")
        let histories = decoder.decodeObject(forKey: "histories") as! [Tab]
        let currentContext = decoder.decodeObject(forKey: "currentContext") as! String
        let backForwardContextList = decoder.decodeObject(forKey: "backForwardContextList") as! [String]
        self.init(groupContext: groupContext, title: title, isPrivate: isPrivate, currentContext: currentContext, histories: histories, backForwardContextList: backForwardContextList)
    }

    public func encode(with encoder: NSCoder) {
        encoder.encode(groupContext, forKey: "groupContext")
        encoder.encode(title, forKey: "title")
        encoder.encode(isPrivate, forKey: "isPrivate")
        encoder.encode(currentContext, forKey: "currentContext")
        encoder.encode(histories, forKey: "histories")
        encoder.encode(backForwardContextList, forKey: "backForwardContextList")
    }
}
