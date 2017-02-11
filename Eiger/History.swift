//
//  History.swift
//  one-hand-browsing
//
//  Created by user1 on 2016/07/29.
//  Copyright © 2016年 eifaniori. All rights reserved.
//

import Foundation
import RealmSwift

class History: Object {
    dynamic var id: String = NSUUID().uuidString
    dynamic var title: String = ""
    dynamic var url: String = ""
    dynamic var date: NSDate = NSDate()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
