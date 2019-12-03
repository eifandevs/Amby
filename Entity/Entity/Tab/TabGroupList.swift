//
//  TabGroupList.swift
//  Model
//
//  Created by tenma on 2019/02/03.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import CommonUtil
import Foundation
import UIKit

// swiftlint:disable force_cast

public class TabGroupList: NSObject, NSCoding, Codable {
    public var currentGroupContext: String
    public var groups: [TabGroup]
    public var currentGroup: TabGroup {
        return groups.find({ $0.groupContext == currentGroupContext })!
    }

    public override init() {
        let tabGroup = TabGroup()
        groups = [tabGroup]
        currentGroupContext = tabGroup.groupContext
    }

    public init(currentGroupContext: String, groups: [TabGroup]) {
        self.currentGroupContext = currentGroupContext
        self.groups = groups
    }

    public required convenience init?(coder decoder: NSCoder) {
        let currentGroupContext = decoder.decodeObject(forKey: "currentGroupContext") as! String
        let groups = decoder.decodeObject(forKey: "groups") as! [TabGroup]
        self.init(currentGroupContext: currentGroupContext, groups: groups)
    }

    public func encode(with encoder: NSCoder) {
        encoder.encode(currentGroupContext, forKey: "currentGroupContext")
        encoder.encode(groups, forKey: "groups")
    }
}
