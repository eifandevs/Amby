//
//  PageGroupList.swift
//  Model
//
//  Created by tenma on 2019/02/03.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import CommonUtil
import Foundation
import UIKit

// swiftlint:disable force_cast

public class PageGroupList: NSObject, NSCoding {
    public var currentGroupContext: String
    public var groups: [PageGroup]
    public var currentGroup: PageGroup {
        return groups.find({ $0.groupContext == currentGroupContext })!
    }

    public override init() {
        let pageGroup = PageGroup()
        groups = [pageGroup]
        currentGroupContext = pageGroup.groupContext
    }

    public init(currentGroupContext: String, groups: [PageGroup]) {
        self.currentGroupContext = currentGroupContext
        self.groups = groups
    }

    public required convenience init?(coder decoder: NSCoder) {
        let currentGroupContext = decoder.decodeObject(forKey: "currentGroupContext") as! String
        let groups = decoder.decodeObject(forKey: "groups") as! [PageGroup]
        self.init(currentGroupContext: currentGroupContext, groups: groups)
    }

    public func encode(with encoder: NSCoder) {
        encoder.encode(currentGroupContext, forKey: "currentGroupContext")
        encoder.encode(groups, forKey: "groups")
    }
}
