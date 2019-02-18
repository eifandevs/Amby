//
//  PageGroup.swift
//  Model
//
//  Created by tenma on 2019/02/02.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import UIKit

// swiftlint:disable force_cast

public class PageGroup: NSObject, NSCoding {
    public var groupContext: String = NSUUID().uuidString
    public var title = "新しいグループ"
    public var isPrivate = false
    public var currentContext = ""
    public var histories = [PageHistory]()

    public override init() {
        super.init()
        setup()
    }

    private func setup() {
        let pageHistory = PageHistory()
        histories = [pageHistory]
        currentContext = pageHistory.context
    }

    public init(groupContext: String, title: String, isPrivate: Bool, currentContext: String, histories: [PageHistory]) {
        self.groupContext = groupContext
        self.title = title
        self.isPrivate = isPrivate
        self.currentContext = currentContext
        self.histories = histories
    }

    public required convenience init?(coder decoder: NSCoder) {
        let groupContext = decoder.decodeObject(forKey: "groupContext") as! String
        let title = decoder.decodeObject(forKey: "title") as! String
        let isPrivate = decoder.decodeBool(forKey: "isPrivate")
        let histories = decoder.decodeObject(forKey: "histories") as! [PageHistory]
        let currentContext = decoder.decodeObject(forKey: "currentContext") as! String
        self.init(groupContext: groupContext, title: title, isPrivate: isPrivate, currentContext: currentContext, histories: histories)
    }

    public func encode(with encoder: NSCoder) {
        encoder.encode(groupContext, forKey: "groupContext")
        encoder.encode(currentContext, forKey: "title")
        encoder.encode(isPrivate, forKey: "isPrivate")
        encoder.encode(currentContext, forKey: "currentContext")
        encoder.encode(histories, forKey: "histories")
    }
}
