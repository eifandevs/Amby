//
//  PageGroupList.swift
//  Model
//
//  Created by tenma on 2019/02/03.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import Foundation
import UIKit

// swiftlint:disable force_cast

public class PageGroupList: NSObject, NSCoding {
    public var currentGroup: Int = 0
    public var groups = [PageGroup]()

    override init() {
        super.init()
    }

    public init(currentGroup: Int = 0, groups: [PageGroup]) {
        self.currentGroup = currentGroup
        self.groups = groups
    }

    public required convenience init?(coder decoder: NSCoder) {
        let currentGroup = decoder.decodeObject(forKey: "currentGroup") as! Int
        let groups = decoder.decodeObject(forKey: "groups") as! [PageGroup]
        self.init(currentGroup: currentGroup, groups: groups)
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(currentGroup, forKey: "currentGroup")
        aCoder.encode(groups, forKey: "groups")
    }
}
