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
    public var isPrivate = false
    public var currentContext = ""
    public var histories = [PageHistory]()

    override init() {
        super.init()
        setup()
    }

    private func setup() {
        isPrivate = false
        let pageHistory = PageHistory()
        histories = [pageHistory]
        currentContext = pageHistory.context
    }

    public init(isPrivate: Bool, currentContext: String, histories: [PageHistory]) {
        self.isPrivate = isPrivate
        self.currentContext = currentContext
        self.histories = histories
    }

    public required convenience init?(coder decoder: NSCoder) {
        let isPrivate = decoder.decodeBool(forKey: "isPrivate") as! Bool
        let histories = decoder.decodeObject(forKey: "histories") as! [PageHistory]
        let currentContext = decoder.decodeObject(forKey: "currentContext") as! String
        self.init(isPrivate: isPrivate, currentContext: currentContext, histories: histories)
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(isPrivate, forKey: "isPrivate")
        aCoder.encode(currentContext, forKey: "currentContext")
        aCoder.encode(histories, forKey: "histories")
    }
}
