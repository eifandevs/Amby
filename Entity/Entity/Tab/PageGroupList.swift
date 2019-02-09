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
    public var currentIndex: Int = 0
    public var groups = [PageGroup]()
    public var currentGroup: PageGroup {
        return groups[currentIndex]
    }

    public override init() {
        super.init()
        setup()
    }

    private func setup() {
        currentIndex = 0
        let pageGroup = PageGroup()
        groups = [pageGroup]
    }

    public init(currentIndex: Int, groups: [PageGroup]) {
        self.currentIndex = currentIndex
        self.groups = groups
    }

    public required convenience init?(coder decoder: NSCoder) {
        let currentIndex = decoder.decodeInteger(forKey: "currentIndex")
        let groups = decoder.decodeObject(forKey: "groups") as! [PageGroup]
        self.init(currentIndex: currentIndex, groups: groups)
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(currentIndex, forKey: "currentIndex")
        aCoder.encode(groups, forKey: "groups")
    }
}
