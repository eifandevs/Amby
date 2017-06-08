//
//  Login.swift
//  one-hand-browsing
//
//  Created by temma on 2016/10/10.
//  Copyright © 2016年 eifaniori. All rights reserved.
//

import Foundation
import RealmSwift

class Form: Object {
    dynamic var id: String = NSUUID().uuidString
    dynamic var title: String? = ""
    dynamic var host: String? = ""
    dynamic var url: String? = ""
    dynamic var date: NSDate = NSDate()
    let inputs = List<Input>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Input: Object {
    dynamic var formIndex: Int = 0
    dynamic var formInputIndex: Int = 0
    dynamic var type: String = ""
    dynamic var value: String = ""
}
