//
//  Form.swift
//  Qas
//
//  Created by temma on 2017/11/12.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import RealmSwift

class Form: Object {
    @objc dynamic var id: String = NSUUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var host: String = ""
    @objc dynamic var url: String = ""
    @objc dynamic var date: Date = Date()
    let inputs = List<Input>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
